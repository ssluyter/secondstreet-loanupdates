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
    async function fetchData() {
      try {
        const res = await fetch(`/api/track/${token}`);
        if (!res.ok) {
          const err = await res.json();
          setError(err.error || 'Unable to load loan status.');
          return;
        }
        const json = await res.json();
        setData(json);
      } catch (e) {
        setError('Unable to connect. Please try again later.');
      } finally {
        setLoading(false);
      }
    }
    fetchData();
  }, [token]);

  // Loading state
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#F5F6FA]">
        <div className="text-center">
          <div className="w-10 h-10 border-3 border-ss-blue/20 border-t-ss-blue rounded-full animate-spin mx-auto mb-4" />
          <p className="text-sm text-gray-400 font-medium">Loading loan status...</p>
        </div>
      </div>
    );
  }

  // Error / not found state
  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#F5F6FA] px-6">
        <div className="text-center max-w-md">
          <div className="w-16 h-16 rounded-2xl bg-navy/5 flex items-center justify-center mx-auto mb-5">
            <svg viewBox="0 0 24 24" fill="none" stroke="#161E5B" strokeWidth="1.5" strokeLinecap="round" className="w-8 h-8">
              <circle cx="12" cy="12" r="10" />
              <path d="M12 8v4M12 16h.01" />
            </svg>
          </div>
          <h1 className="font-serif text-2xl text-navy mb-2">Link not found</h1>
          <p className="text-sm text-gray-500 leading-relaxed mb-6">{error}</p>
          <p className="text-xs text-gray-400">
            Need help? Contact us at{' '}
            <a href="mailto:info@mysecondstreet.com" className="text-ss-blue hover:text-ss-blue-hover">
              info@mysecondstreet.com
            </a>
          </p>
        </div>
      </div>
    );
  }

  const completedCount = data.milestones.filter(m => m.status === 'done').length;
  const activeMilestone = data.milestones.find(m => m.status === 'active');
  const totalSteps = data.milestones.length;

  return (
    <div className="min-h-screen bg-[#F5F6FA]">
      {/* ══ HERO HEADER ══ */}
      <div className="bg-gradient-to-br from-navy via-[#1a2468] to-ss-blue relative overflow-hidden">
        {/* Decorative circles */}
        <div className="absolute -top-10 -right-10 w-40 h-40 rounded-full bg-white/[0.04]" />
        <div className="absolute -bottom-6 right-20 w-24 h-24 rounded-full bg-white/[0.03]" />
        <div className="absolute top-8 -left-5 w-16 h-16 rounded-full bg-white/[0.02]" />

        <div className="max-w-3xl mx-auto px-6 py-10 relative z-10">
          {/* Logo area */}
          <div className="flex items-center gap-2 mb-8 opacity-0 animate-fade-in-up">
            <span className="font-serif text-lg text-white tracking-wide">Second Street</span>
            <span className="text-white/40 text-xs font-medium uppercase tracking-widest ml-2">Loan Status</span>
          </div>

          {/* Ring + Info */}
          <div className="flex items-center gap-6 flex-wrap">
            <div className="opacity-0 animate-fade-in-up stagger-1">
              <ProgressRing completed={completedCount} total={totalSteps} />
            </div>
            <div className="opacity-0 animate-fade-in-up stagger-2">
              <h1 className="font-serif text-2xl text-white mb-1">
                {data.borrower_first_name} {data.borrower_last_name}
              </h1>
              <p className="text-sm text-white/70 leading-relaxed">
                {data.property_address}
              </p>
              {data.estimated_closing && (
                <div className="mt-2 text-xs font-semibold text-white/90">
                  Est. closing:{' '}
                  <span className="bg-white/15 px-2.5 py-0.5 rounded-full ml-1">{data.estimated_closing}</span>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* ══ CONTENT ══ */}
      <div className="max-w-3xl mx-auto px-6 -mt-6 relative z-20 pb-12">
        {/* Stat cards */}
        <div className="flex gap-3 mb-6 flex-wrap">
          <div className="flex-1 min-w-[140px] bg-white rounded-xl p-4 shadow-sm border border-ss-border opacity-0 animate-fade-in-up stagger-3">
            <div className="text-[11px] font-medium text-gray-400 uppercase tracking-wider mb-1">Steps done</div>
            <div className="text-xl font-bold text-navy">{completedCount} / {totalSteps}</div>
          </div>
          <div className="flex-1 min-w-[140px] bg-white rounded-xl p-4 shadow-sm border border-ss-border opacity-0 animate-fade-in-up stagger-4">
            <div className="text-[11px] font-medium text-gray-400 uppercase tracking-wider mb-1">Current step</div>
            <div className={`text-sm font-bold leading-snug ${activeMilestone ? 'text-ss-blue' : 'text-ss-green'}`}>
              {activeMilestone ? activeMilestone.label : 'Complete!'}
            </div>
          </div>
          {data.estimated_closing && (
            <div className="flex-1 min-w-[140px] bg-white rounded-xl p-4 shadow-sm border border-ss-border opacity-0 animate-fade-in-up stagger-5">
              <div className="text-[11px] font-medium text-gray-400 uppercase tracking-wider mb-1">Est. closing</div>
              <div className="text-sm font-bold text-navy">{data.estimated_closing}</div>
            </div>
          )}
        </div>

        {/* Section label */}
        <div className="text-xs font-semibold text-gray-400 uppercase tracking-widest mb-3 ml-1">
          Loan milestones
        </div>

        {/* Milestone grid */}
        <div className="grid grid-cols-[repeat(auto-fill,minmax(155px,1fr))] gap-3">
          {data.milestones.map((m, i) => (
            <MilestoneCard key={m.step} milestone={m} index={i} />
          ))}
        </div>

        {/* Loan officer card */}
        <LoanOfficerCard
          name={data.lo_name}
          email={data.lo_email}
          phone={data.lo_phone}
        />

        {/* Footer */}
        <div className="mt-8 text-center text-xs text-gray-400 leading-relaxed">
          <p className="font-medium text-gray-500 mb-1">Second Street Inc. &bull; Second Street CR, S.R.L.</p>
          <p>This page updates automatically as your loan progresses.</p>
          <p className="mt-2">
            Questions?{' '}
            <a href="mailto:info@mysecondstreet.com" className="text-ss-blue hover:text-ss-blue-hover">info@mysecondstreet.com</a>
            {' '}&bull;{' '}
            <a href="tel:+18007001002" className="text-ss-blue hover:text-ss-blue-hover">+1 (800) 700-1002</a>
          </p>
        </div>
      </div>
    </div>
  );
}
