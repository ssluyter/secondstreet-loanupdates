#!/bin/bash
# ══════════════════════════════════════════════════════════
# Second Street Status Tracker — Project Setup Script
# This script creates all project files in the current directory.
# Render build command: bash setup.sh && npm run render-build
# ══════════════════════════════════════════════════════════

set -e

echo "Creating project files..."

# ── server/package.json ──
mkdir -p server
cat > server/package.json << 'ENDFILE'
{
  "name": "ss-status-tracker-server",
  "version": "1.0.0",
  "dependencies": {
    "cors": "^2.8.5",
    "dotenv": "^16.4.0",
    "express": "^4.18.2",
    "node-fetch": "^2.7.0"
  }
}
ENDFILE

# ── server/digifi.js ──
cat > server/digifi.js << 'ENDFILE'
const fetch = require('node-fetch');

const DIGIFI_BASE = process.env.DIGIFI_API_BASE_URL || 'https://api.digifi.io/v1';
const DIGIFI_KEY = process.env.DIGIFI_API_KEY;
const TOKEN_VAR = process.env.DIGIFI_TRACKING_TOKEN_VAR || 'tracking_token';

const VAR_MAP = {
  borrower_first_name: 'borrower_first_name',
  borrower_last_name: 'borrower_last_name',
  property_address: 'borrower_cr_subject_address_tracker',
  pal_delivery_date: 'pal_delivery_date',
  appraisal_ordered: 'property_appraisal_request_date',
  appraisal_received: 'property_appraisal_delivered_date',
  dd_ordered: 'property_due_diligence_ordered_date',
  dd_cleared: 'property_due_diligence_delivered_date',
  escrow_opened: 'trust_and_escrow_request_date',
  escrow_open_date: 'trust_and_escrow_received_date',
  clear_to_close: 'clear_to_close_date',
  closing_scheduled: 'closing_scheduled_date',
  funded: 'funded_date',
  estimated_closing: 'estimated_closing_date',
  lo_name: 'lo_name',
  lo_email: 'lo_email',
  lo_phone: 'lo_phone',
  tracking_token: TOKEN_VAR,
};

const MOCK_DATA = {
  borrower_first_name: 'John',
  borrower_last_name: 'Garcia',
  property_address: '123 Playa Hermosa, Guanacaste, Costa Rica',
  estimated_closing: 'March 15, 2026',
  lo_name: 'Raj Ponniah',
  lo_email: 'raj@mysecondstreet.com',
  lo_phone: '+1 (800) 700-1002',
  milestones: [
    { step: 1, label: 'Application received', date: null, noDate: true, status: 'done' },
    { step: 2, label: 'Submitted to underwriting', date: null, noDate: true, status: 'done' },
    { step: 3, label: 'Pre-approval issued', date: 'Jan 15, 2026', noDate: false, status: 'done' },
    { step: 4, label: 'Appraisal ordered', date: 'Jan 18, 2026', noDate: false, status: 'done' },
    { step: 5, label: 'Appraisal received', date: 'Feb 3, 2026', noDate: false, status: 'done' },
    { step: 6, label: 'Due diligence ordered', date: 'Feb 5, 2026', noDate: false, status: 'done' },
    { step: 7, label: 'Due diligence cleared', date: 'Feb 18, 2026', noDate: false, status: 'done' },
    { step: 8, label: 'Open escrow', date: null, noDate: false, status: 'active' },
    { step: 9, label: 'Escrow open date', date: null, noDate: false, status: 'pending' },
    { step: 10, label: 'Clear to close', date: null, noDate: false, status: 'pending' },
    { step: 11, label: 'Closing scheduled', date: null, noDate: false, status: 'pending' },
    { step: 12, label: 'Funded', date: null, noDate: false, status: 'pending' },
  ],
};

function hasDate(val) {
  return val && typeof val === 'string' && val.trim() !== '';
}

function buildMilestones(vars) {
  const raw = [
    { step: 1, label: 'Application received', dateKey: null, noDate: true },
    { step: 2, label: 'Submitted to underwriting', dateKey: null, noDate: true },
    { step: 3, label: 'Pre-approval issued', dateKey: 'pal_delivery_date', noDate: false },
    { step: 4, label: 'Appraisal ordered', dateKey: 'appraisal_ordered', noDate: false },
    { step: 5, label: 'Appraisal received', dateKey: 'appraisal_received', noDate: false },
    { step: 6, label: 'Due diligence ordered', dateKey: 'dd_ordered', noDate: false },
    { step: 7, label: 'Due diligence cleared', dateKey: 'dd_cleared', noDate: false },
    { step: 8, label: 'Open escrow', dateKey: 'escrow_opened', noDate: false },
    { step: 9, label: 'Escrow open date', dateKey: 'escrow_open_date', noDate: false },
    { step: 10, label: 'Clear to close', dateKey: 'clear_to_close', noDate: false },
    { step: 11, label: 'Closing scheduled', dateKey: 'closing_scheduled', noDate: false },
    { step: 12, label: 'Funded', dateKey: 'funded', noDate: false },
  ];
  const anyLaterHasDate = raw.slice(2).some(function(m) {
    if (m.noDate || !m.dateKey) return false;
    var varName = VAR_MAP[m.dateKey];
    return hasDate(vars[varName]);
  });
  var firstPending = -1;
  return raw.map(function(m, i) {
    var date = null;
    var status;
    if (m.dateKey && VAR_MAP[m.dateKey]) date = vars[VAR_MAP[m.dateKey]] || null;
    if (i === 0) { status = 'done'; }
    else if (i === 1) {
      status = anyLaterHasDate ? 'done' : (firstPending === -1 ? 'active' : 'pending');
      if (status !== 'done' && firstPending === -1) firstPending = i;
    } else {
      if (hasDate(date)) { status = 'done'; }
      else { status = firstPending === -1 ? 'active' : 'pending'; if (firstPending === -1) firstPending = i; }
    }
    return { step: m.step, label: m.label, date: hasDate(date) ? date : null, noDate: m.noDate, status: status };
  });
}

async function getApplicationByToken(token) {
  if (!DIGIFI_KEY || DIGIFI_KEY === 'your_digifi_api_key_here') {
    console.log('[DEV] No Digifi API key — returning mock data');
    if (token === 'demo' || token === 'test') return { success: true, data: MOCK_DATA };
    return { success: false, error: 'not_found' };
  }
  try {
    var searchUrl = DIGIFI_BASE + '/applications?variables.' + TOKEN_VAR + '=' + encodeURIComponent(token) + '&limit=1';
    var response = await fetch(searchUrl, {
      headers: { 'Authorization': 'Bearer ' + DIGIFI_KEY, 'Content-Type': 'application/json' },
    });
    if (!response.ok) { console.error('Digifi API error: ' + response.status); return { success: false, error: 'api_error' }; }
    var result = await response.json();
    var applications = result.data || result.applications || result;
    if (!applications || (Array.isArray(applications) && applications.length === 0)) return { success: false, error: 'not_found' };
    var app = Array.isArray(applications) ? applications[0] : applications;
    var vars = app.variables || {};
    var milestones = buildMilestones(vars);
    var completedCount = milestones.filter(function(m) { return m.status === 'done'; }).length;
    return {
      success: true,
      data: {
        borrower_first_name: vars[VAR_MAP.borrower_first_name] || '',
        borrower_last_name: vars[VAR_MAP.borrower_last_name] || '',
        property_address: vars[VAR_MAP.property_address] || '',
        estimated_closing: vars[VAR_MAP.estimated_closing] || null,
        lo_name: vars[VAR_MAP.lo_name] || '',
        lo_email: vars[VAR_MAP.lo_email] || '',
        lo_phone: vars[VAR_MAP.lo_phone] || '',
        milestones: milestones,
        completed_count: completedCount,
        total_steps: 12,
      },
    };
  } catch (err) {
    console.error('Digifi API fetch error:', err.message);
    return { success: false, error: 'api_error' };
  }
}

module.exports = { getApplicationByToken, MOCK_DATA };
ENDFILE

# ── server/index.js ──
cat > server/index.js << 'ENDFILE'
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
var express = require('express');
var cors = require('cors');
var path = require('path');
var digifi = require('./digifi');

var app = express();
var PORT = process.env.PORT || 3001;
var CLIENT_URL = process.env.CLIENT_URL || 'http://localhost:5173';

app.use(cors({ origin: CLIENT_URL }));
app.use(express.json());

var rateLimitMap = new Map();
function rateLimit(req, res, next) {
  var ip = req.ip || req.connection.remoteAddress;
  var now = Date.now();
  var entry = rateLimitMap.get(ip);
  if (!entry || now - entry.start > 60000) { rateLimitMap.set(ip, { start: now, count: 1 }); return next(); }
  entry.count++;
  if (entry.count > 30) return res.status(429).json({ error: 'Too many requests.' });
  next();
}

app.get('/api/track/:token', rateLimit, async function(req, res) {
  var token = req.params.token;
  if (!token || token.length < 4 || token.length > 64 || !/^[a-zA-Z0-9\-_]+$/.test(token)) {
    return res.status(400).json({ error: 'Invalid tracking code.' });
  }
  try {
    var result = await digifi.getApplicationByToken(token);
    if (!result.success) {
      if (result.error === 'not_found') return res.status(404).json({ error: 'No loan found for this tracking code.' });
      return res.status(502).json({ error: 'Unable to retrieve loan status.' });
    }
    return res.json(result.data);
  } catch (err) {
    console.error('Track error:', err);
    return res.status(500).json({ error: 'An unexpected error occurred.' });
  }
});

app.get('/api/health', function(req, res) { res.json({ status: 'ok' }); });

if (process.env.NODE_ENV === 'production') {
  var clientBuild = path.join(__dirname, '..', 'client', 'dist');
  app.use(express.static(clientBuild));
  app.get('*', function(req, res) {
    if (!req.path.startsWith('/api')) res.sendFile(path.join(clientBuild, 'index.html'));
  });
}

app.listen(PORT, function() {
  console.log('Second Street Status Tracker running on port ' + PORT);
  if (!process.env.DIGIFI_API_KEY || process.env.DIGIFI_API_KEY === 'your_digifi_api_key_here') {
    console.log('No Digifi API key — using mock data. Test: /api/track/demo');
  }
});
ENDFILE

# ── client files ──
mkdir -p client/src/components client/src/pages

cat > client/package.json << 'ENDFILE'
{
  "name": "ss-status-tracker-client",
  "private": true,
  "version": "1.0.0",
  "scripts": { "dev": "vite", "build": "vite build", "preview": "vite preview" },
  "dependencies": { "react": "^18.2.0", "react-dom": "^18.2.0", "react-router-dom": "^6.20.0" },
  "devDependencies": { "@vitejs/plugin-react": "^4.2.0", "autoprefixer": "^10.4.16", "postcss": "^8.4.32", "tailwindcss": "^3.4.0", "vite": "^5.0.0" }
}
ENDFILE

cat > client/vite.config.js << 'ENDFILE'
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
export default defineConfig({
  plugins: [react()],
  server: { port: 5173, proxy: { '/api': 'http://localhost:3001' } },
});
ENDFILE

cat > client/tailwind.config.js << 'ENDFILE'
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        navy: '#161E5B', 'ss-blue': '#1F58FB', 'ss-blue-hover': '#1549d8',
        'ss-light': '#EEF1FA', 'ss-border': '#DDE3F2', 'ss-bg': '#F8F9FD',
        'ss-green': '#0F6E56', 'ss-green-light': '#E8F5EE',
      },
      fontFamily: { sans: ['Montserrat', 'sans-serif'], serif: ['"DM Serif Display"', 'serif'] },
    },
  },
  plugins: [],
};
ENDFILE

cat > client/postcss.config.js << 'ENDFILE'
export default { plugins: { tailwindcss: {}, autoprefixer: {} } };
ENDFILE

cat > client/index.html << 'ENDFILE'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Loan Status — Second Street</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=DM+Serif+Display&family=Montserrat:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body><div id="root"></div><script type="module" src="/src/main.jsx"></script></body>
</html>
ENDFILE

cat > client/src/index.css << 'ENDFILE'
@tailwind base;
@tailwind components;
@tailwind utilities;
body { font-family: 'Montserrat', sans-serif; background: #F5F6FA; min-height: 100vh; }
@keyframes pulse-dot { 0%,100%{opacity:1;transform:scale(1)} 50%{opacity:.5;transform:scale(.8)} }
@keyframes fade-in-up { from{opacity:0;transform:translateY(16px)} to{opacity:1;transform:translateY(0)} }
.animate-fade-in-up { animation: fade-in-up 0.5s ease-out forwards; }
.animate-pulse-dot { animation: pulse-dot 2s ease-in-out infinite; }
.stagger-1{animation-delay:.05s} .stagger-2{animation-delay:.1s} .stagger-3{animation-delay:.15s}
.stagger-4{animation-delay:.2s} .stagger-5{animation-delay:.25s} .stagger-6{animation-delay:.3s}
.stagger-7{animation-delay:.35s} .stagger-8{animation-delay:.4s} .stagger-9{animation-delay:.45s}
.stagger-10{animation-delay:.5s} .stagger-11{animation-delay:.55s} .stagger-12{animation-delay:.6s}
ENDFILE

cat > client/src/main.jsx << 'ENDFILE'
import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import './index.css';
import TrackerPage from './pages/TrackerPage';
import NotFoundPage from './pages/NotFoundPage';
ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <BrowserRouter>
      <Routes>
        <Route path="/track/:token" element={<TrackerPage />} />
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
    </BrowserRouter>
  </React.StrictMode>
);
ENDFILE

cat > client/src/components/ProgressRing.jsx << 'ENDFILE'
import React, { useEffect, useState } from 'react';
export default function ProgressRing({ completed, total }) {
  const [offset, setOffset] = useState(207.3);
  const pct = Math.round((completed / total) * 100);
  const circumference = 207.3;
  useEffect(() => { const t = setTimeout(() => setOffset(circumference - (circumference * pct / 100)), 300); return () => clearTimeout(t); }, [pct]);
  return (
    <div className="relative w-[88px] h-[88px] flex-shrink-0">
      <svg viewBox="0 0 80 80" className="-rotate-90">
        <circle cx="40" cy="40" r="33" fill="none" stroke="rgba(255,255,255,0.15)" strokeWidth="5" />
        <circle cx="40" cy="40" r="33" fill="none" stroke="#fff" strokeWidth="5" strokeLinecap="round"
          strokeDasharray={circumference} strokeDashoffset={offset} style={{transition:'stroke-dashoffset 1.2s ease'}} />
      </svg>
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <span className="text-[22px] font-bold text-white leading-none">{pct}%</span>
        <span className="text-[9px] text-white/60 uppercase tracking-wider mt-0.5">Complete</span>
      </div>
    </div>
  );
}
ENDFILE

cat > client/src/components/MilestoneIcons.jsx << 'ENDFILE'
import React from 'react';
const icons = [
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M10 3v7l4 3"/><circle cx="10" cy="10" r="7"/></svg>,
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M4 10h12M10 4v12"/><rect x="3" y="3" width="14" height="14" rx="3"/></svg>,
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M6 10l3 3 5-6"/><circle cx="10" cy="10" r="7"/></svg>,
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M4 14l4-8h4l4 8M6 11h8"/></svg>,
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M3 16V6l7-3 7 3v10l-7 3z"/><path d="M10 3v16"/></svg>,
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M5 4h10a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2V6a2 2 0 012-2z"/><path d="M7 8h6M7 11h4"/></svg>,
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M6 10l3 3 5-6"/><rect x="3" y="3" width="14" height="14" rx="2"/></svg>,
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M10 3v4M6 5l2 3M14 5l-2 3"/><rect x="4" y="10" width="12" height="6" rx="2"/></svg>,
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><circle cx="10" cy="10" r="7"/><path d="M10 6v4h3"/></svg>,
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M6 10l3 3 5-6"/><circle cx="10" cy="10" r="7"/></svg>,
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M4 6h12M4 10h12M4 14h12"/></svg>,
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M10 3l2 4 5 1-4 3 1 5-4-2-4 2 1-5-4-3 5-1z"/></svg>,
];
export default function MilestoneIcon({ step }) { return icons[step - 1] || icons[0]; }
ENDFILE

cat > client/src/components/MilestoneCard.jsx << 'ENDFILE'
import React from 'react';
import MilestoneIcon from './MilestoneIcons';
export default function MilestoneCard({ milestone }) {
  const { step, label, date, noDate, status } = milestone;
  const cardCls = { done:'bg-white border-[1.5px] border-ss-blue/20 shadow-sm hover:border-ss-blue/40 hover:shadow-md hover:-translate-y-0.5 transition-all', active:'bg-white border-2 border-ss-blue shadow-[0_0_0_4px_rgba(31,88,251,0.1),0_2px_12px_rgba(22,30,91,0.06)]', pending:'bg-ss-bg border-[1.5px] border-dashed border-ss-border opacity-55' };
  const iconCls = { done:'bg-ss-blue/[0.08] text-ss-blue', active:'bg-ss-blue/[0.12] text-ss-blue', pending:'bg-gray-100 text-gray-300' };
  return (
    <div className={`rounded-xl p-4 relative cursor-default opacity-0 animate-fade-in-up stagger-${step} ${cardCls[status]}`}>
      <div className={`w-8 h-8 rounded-lg flex items-center justify-center mb-2.5 ${iconCls[status]}`}><div className="w-[18px] h-[18px]"><MilestoneIcon step={step}/></div></div>
      {status==='done'&&<div className="absolute top-3 right-3 w-5 h-5 rounded-full bg-ss-blue flex items-center justify-center"><svg viewBox="0 0 12 12" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" className="w-[11px] h-[11px]"><path d="M2.5 6l2.5 2.5 4.5-5"/></svg></div>}
      <div className={`text-[10px] font-semibold uppercase tracking-wider mb-1 ${status==='pending'?'text-gray-300':'text-ss-blue'}`}>Step {step}</div>
      <div className={`text-[13px] leading-snug mb-2 ${status==='pending'?'text-gray-400 font-medium':'text-navy font-semibold'}`}>{label}</div>
      {status==='done'&&(noDate||!date?<div className="text-[11px] font-semibold text-ss-green">Complete</div>:<div className="text-[11px] font-semibold text-ss-blue">{date}</div>)}
      {status==='active'&&<div className="text-[11px] font-semibold text-ss-blue italic flex items-center gap-1.5"><span className="inline-block w-2 h-2 rounded-full bg-ss-blue animate-pulse-dot"/>In progress</div>}
      {status==='pending'&&<div className="text-[11px] text-gray-300 italic">Pending</div>}
    </div>
  );
}
ENDFILE

cat > client/src/components/LoanOfficerCard.jsx << 'ENDFILE'
import React from 'react';
export default function LoanOfficerCard({ name, email, phone }) {
  if (!name) return null;
  const initials = name.split(' ').map(n=>n[0]).join('').slice(0,2).toUpperCase();
  return (
    <div className="bg-white rounded-xl border border-ss-border p-5 mt-4 opacity-0 animate-fade-in-up stagger-6">
      <div className="text-[11px] font-semibold text-gray-400 uppercase tracking-wider mb-3">Your loan officer</div>
      <div className="flex items-center gap-3">
        <div className="w-11 h-11 rounded-full bg-navy flex items-center justify-center text-white font-semibold text-sm flex-shrink-0">{initials}</div>
        <div className="min-w-0">
          <div className="text-[15px] font-semibold text-navy">{name}</div>
          <div className="flex flex-wrap gap-x-4 gap-y-0.5 mt-0.5">
            {email&&<a href={'mailto:'+email} className="text-[12px] text-ss-blue hover:text-ss-blue-hover">{email}</a>}
            {phone&&<a href={'tel:'+phone} className="text-[12px] text-ss-blue hover:text-ss-blue-hover">{phone}</a>}
          </div>
        </div>
      </div>
    </div>
  );
}
ENDFILE

cat > client/src/pages/TrackerPage.jsx << 'ENDFILE'
import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import ProgressRing from '../components/ProgressRing';
import MilestoneCard from '../components/MilestoneCard';
import LoanOfficerCard from '../components/LoanOfficerCard';
export default function TrackerPage() {
  const { token } = useParams();
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    (async () => {
      try {
        const res = await fetch('/api/track/'+token);
        if (!res.ok) { const e = await res.json(); setError(e.error||'Unable to load.'); return; }
        setData(await res.json());
      } catch(e) { setError('Unable to connect.'); }
      finally { setLoading(false); }
    })();
  }, [token]);
  if (loading) return (
    <div className="min-h-screen flex items-center justify-center bg-[#F5F6FA]">
      <div className="text-center">
        <div className="w-10 h-10 border-[3px] border-ss-blue/20 border-t-ss-blue rounded-full animate-spin mx-auto mb-4"/>
        <p className="text-sm text-gray-400 font-medium">Loading loan status...</p>
      </div>
    </div>
  );
  if (error) return (
    <div className="min-h-screen flex items-center justify-center bg-[#F5F6FA] px-6">
      <div className="text-center max-w-md">
        <div className="w-16 h-16 rounded-2xl bg-navy/5 flex items-center justify-center mx-auto mb-5">
          <svg viewBox="0 0 24 24" fill="none" stroke="#161E5B" strokeWidth="1.5" strokeLinecap="round" className="w-8 h-8"><circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/></svg>
        </div>
        <h1 className="font-serif text-2xl text-navy mb-2">Link not found</h1>
        <p className="text-sm text-gray-500 leading-relaxed mb-6">{error}</p>
        <p className="text-xs text-gray-400">Need help? <a href="mailto:info@mysecondstreet.com" className="text-ss-blue">info@mysecondstreet.com</a></p>
      </div>
    </div>
  );
  const done = data.milestones.filter(m=>m.status==='done').length;
  const active = data.milestones.find(m=>m.status==='active');
  const total = data.milestones.length;
  return (
    <div className="min-h-screen bg-[#F5F6FA]">
      <div className="bg-gradient-to-br from-navy via-[#1a2468] to-ss-blue relative overflow-hidden">
        <div className="absolute -top-10 -right-10 w-40 h-40 rounded-full bg-white/[0.04]"/>
        <div className="absolute -bottom-6 right-20 w-24 h-24 rounded-full bg-white/[0.03]"/>
        <div className="absolute top-8 -left-5 w-16 h-16 rounded-full bg-white/[0.02]"/>
        <div className="max-w-3xl mx-auto px-6 py-10 relative z-10">
          <div className="flex items-center gap-2 mb-8 opacity-0 animate-fade-in-up">
            <span className="font-serif text-lg text-white tracking-wide">Second Street</span>
            <span className="text-white/40 text-xs font-medium uppercase tracking-widest ml-2">Loan Status</span>
          </div>
          <div className="flex items-center gap-6 flex-wrap">
            <div className="opacity-0 animate-fade-in-up stagger-1"><ProgressRing completed={done} total={total}/></div>
            <div className="opacity-0 animate-fade-in-up stagger-2">
              <h1 className="font-serif text-2xl text-white mb-1">{data.borrower_first_name} {data.borrower_last_name}</h1>
              <p className="text-sm text-white/70 leading-relaxed">{data.property_address}</p>
              {data.estimated_closing&&<div className="mt-2 text-xs font-semibold text-white/90">Est. closing: <span className="bg-white/15 px-2.5 py-0.5 rounded-full ml-1">{data.estimated_closing}</span></div>}
            </div>
          </div>
        </div>
      </div>
      <div className="max-w-3xl mx-auto px-6 -mt-6 relative z-20 pb-12">
        <div className="flex gap-3 mb-6 flex-wrap">
          <div className="flex-1 min-w-[140px] bg-white rounded-xl p-4 shadow-sm border border-ss-border opacity-0 animate-fade-in-up stagger-3">
            <div className="text-[11px] font-medium text-gray-400 uppercase tracking-wider mb-1">Steps done</div>
            <div className="text-xl font-bold text-navy">{done} / {total}</div>
          </div>
          <div className="flex-1 min-w-[140px] bg-white rounded-xl p-4 shadow-sm border border-ss-border opacity-0 animate-fade-in-up stagger-4">
            <div className="text-[11px] font-medium text-gray-400 uppercase tracking-wider mb-1">Current step</div>
            <div className={`text-sm font-bold leading-snug ${active?'text-ss-blue':'text-ss-green'}`}>{active?active.label:'Complete!'}</div>
          </div>
          {data.estimated_closing&&<div className="flex-1 min-w-[140px] bg-white rounded-xl p-4 shadow-sm border border-ss-border opacity-0 animate-fade-in-up stagger-5">
            <div className="text-[11px] font-medium text-gray-400 uppercase tracking-wider mb-1">Est. closing</div>
            <div className="text-sm font-bold text-navy">{data.estimated_closing}</div>
          </div>}
        </div>
        <div className="text-xs font-semibold text-gray-400 uppercase tracking-widest mb-3 ml-1">Loan milestones</div>
        <div className="grid grid-cols-[repeat(auto-fill,minmax(155px,1fr))] gap-3">
          {data.milestones.map(m=><MilestoneCard key={m.step} milestone={m}/>)}
        </div>
        <LoanOfficerCard name={data.lo_name} email={data.lo_email} phone={data.lo_phone}/>
        <div className="mt-8 text-center text-xs text-gray-400 leading-relaxed">
          <p className="font-medium text-gray-500 mb-1">Second Street Inc. &bull; Second Street CR, S.R.L.</p>
          <p>This page updates automatically as your loan progresses.</p>
          <p className="mt-2">Questions? <a href="mailto:info@mysecondstreet.com" className="text-ss-blue">info@mysecondstreet.com</a> &bull; <a href="tel:+18007001002" className="text-ss-blue">+1 (800) 700-1002</a></p>
        </div>
      </div>
    </div>
  );
}
ENDFILE

cat > client/src/pages/NotFoundPage.jsx << 'ENDFILE'
import React from 'react';
export default function NotFoundPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-[#F5F6FA] px-6">
      <div className="text-center max-w-md">
        <div className="w-16 h-16 rounded-2xl bg-navy/5 flex items-center justify-center mx-auto mb-5">
          <svg viewBox="0 0 24 24" fill="none" stroke="#161E5B" strokeWidth="1.5" strokeLinecap="round" className="w-8 h-8"><path d="M3 12h18M12 3v18"/><circle cx="12" cy="12" r="10"/></svg>
        </div>
        <h1 className="font-serif text-2xl text-navy mb-2">Second Street</h1>
        <p className="text-sm text-gray-500 leading-relaxed mb-6">This page requires a valid tracking link. If you received a link from your loan officer, please try clicking it again or copying the full URL.</p>
        <p className="text-xs text-gray-400">Need help? <a href="mailto:info@mysecondstreet.com" className="text-ss-blue">info@mysecondstreet.com</a> &bull; <a href="tel:+18007001002" className="text-ss-blue">+1 (800) 700-1002</a></p>
      </div>
    </div>
  );
}
ENDFILE

echo "All files created successfully!"
