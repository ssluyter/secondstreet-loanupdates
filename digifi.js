const fetch = require('node-fetch');

// ══════════════════════════════════════════════════
// DIGIFI API CLIENT
// Searches for applications by tracking_token variable
// and returns milestone dates + loan info
// ══════════════════════════════════════════════════

const DIGIFI_BASE = process.env.DIGIFI_API_BASE_URL || 'https://api.digifi.io/v1';
const DIGIFI_KEY = process.env.DIGIFI_API_KEY;
const TOKEN_VAR = process.env.DIGIFI_TRACKING_TOKEN_VAR || 'tracking_token';

// Variable system names — UPDATE THESE to match your Digifi config
const VAR_MAP = {
  // Borrower info
  borrower_first_name: 'borrower_first_name',
  borrower_last_name: 'borrower_last_name',
  property_address: 'borrower_cr_subject_address_tracker',

  // Milestone dates (confirmed)
  pal_delivery_date: 'pal_delivery_date',
  appraisal_ordered: 'property_appraisal_request_date',
  appraisal_received: 'property_appraisal_delivered_date',
  dd_ordered: 'property_due_diligence_ordered_date',
  dd_cleared: 'property_due_diligence_delivered_date',
  escrow_opened: 'trust_and_escrow_request_date',
  escrow_open_date: 'trust_and_escrow_received_date',

  // Milestone dates (placeholders — create in Digifi when ready)
  clear_to_close: 'clear_to_close_date',
  closing_scheduled: 'closing_scheduled_date',
  funded: 'funded_date',
  estimated_closing: 'estimated_closing_date',

  // Loan officer info — UPDATE THESE to your actual variable names
  lo_name: 'lo_name',           // placeholder — replace with actual
  lo_email: 'lo_email',         // placeholder — replace with actual
  lo_phone: 'lo_phone',         // placeholder — replace with actual

  // Tracking
  tracking_token: TOKEN_VAR,
};

// ── Mock data for development (used when no API key is configured) ──
const MOCK_DATA = {
  borrower_first_name: 'John',
  borrower_last_name: 'Garcia',
  property_address: '123 Playa Hermosa, Guanacaste, Costa Rica',
  estimated_closing: 'March 15, 2026',
  lo_name: 'Raj Ponniah',
  lo_email: 'raj@mysecondstreet.com',
  lo_phone: '+1 (800) 700-1002',
  milestones: [
    { step: 1,  label: 'Application received',       date: null,              noDate: true,  status: 'done' },
    { step: 2,  label: 'Submitted to underwriting',  date: null,              noDate: true,  status: 'done' },
    { step: 3,  label: 'Pre-approval issued',        date: 'Jan 15, 2026',   noDate: false, status: 'done' },
    { step: 4,  label: 'Appraisal ordered',          date: 'Jan 18, 2026',   noDate: false, status: 'done' },
    { step: 5,  label: 'Appraisal received',         date: 'Feb 3, 2026',    noDate: false, status: 'done' },
    { step: 6,  label: 'Due diligence ordered',      date: 'Feb 5, 2026',    noDate: false, status: 'done' },
    { step: 7,  label: 'Due diligence cleared',      date: 'Feb 18, 2026',   noDate: false, status: 'done' },
    { step: 8,  label: 'Open escrow',                date: null,              noDate: false, status: 'active' },
    { step: 9,  label: 'Escrow open date',           date: null,              noDate: false, status: 'pending' },
    { step: 10, label: 'Clear to close',             date: null,              noDate: false, status: 'pending' },
    { step: 11, label: 'Closing scheduled',          date: null,              noDate: false, status: 'pending' },
    { step: 12, label: 'Funded',                     date: null,              noDate: false, status: 'pending' },
  ],
};

// ── Helper: check if a value is a real date ──
function hasDate(val) {
  return val && typeof val === 'string' && val.trim() !== '';
}

// ── Build milestones array from Digifi variables ──
function buildMilestones(vars) {
  const raw = [
    { step: 1,  label: 'Application received',       dateKey: null,              noDate: true },
    { step: 2,  label: 'Submitted to underwriting',  dateKey: null,              noDate: true },
    { step: 3,  label: 'Pre-approval issued',        dateKey: 'pal_delivery_date', noDate: false },
    { step: 4,  label: 'Appraisal ordered',          dateKey: 'appraisal_ordered',  noDate: false },
    { step: 5,  label: 'Appraisal received',         dateKey: 'appraisal_received', noDate: false },
    { step: 6,  label: 'Due diligence ordered',      dateKey: 'dd_ordered',         noDate: false },
    { step: 7,  label: 'Due diligence cleared',      dateKey: 'dd_cleared',         noDate: false },
    { step: 8,  label: 'Open escrow',                dateKey: 'escrow_opened',      noDate: false },
    { step: 9,  label: 'Escrow open date',           dateKey: 'escrow_open_date',   noDate: false },
    { step: 10, label: 'Clear to close',             dateKey: 'clear_to_close',     noDate: false },
    { step: 11, label: 'Closing scheduled',          dateKey: 'closing_scheduled',  noDate: false },
    { step: 12, label: 'Funded',                     dateKey: 'funded',             noDate: false },
  ];

  // Check if any dated step (3+) has a value — used for step 2 logic
  const anyLaterHasDate = raw.slice(2).some(m => {
    if (m.noDate || !m.dateKey) return false;
    const varName = VAR_MAP[m.dateKey];
    return hasDate(vars[varName]);
  });

  let firstPending = -1;
  const milestones = raw.map((m, i) => {
    let date = null;
    let status;

    if (m.dateKey && VAR_MAP[m.dateKey]) {
      date = vars[VAR_MAP[m.dateKey]] || null;
    }

    if (i === 0) {
      status = 'done';
    } else if (i === 1) {
      status = anyLaterHasDate ? 'done' : (firstPending === -1 ? 'active' : 'pending');
      if (status !== 'done' && firstPending === -1) firstPending = i;
    } else {
      if (hasDate(date)) {
        status = 'done';
      } else {
        status = firstPending === -1 ? 'active' : 'pending';
        if (firstPending === -1) firstPending = i;
      }
    }

    return {
      step: m.step,
      label: m.label,
      date: hasDate(date) ? date : null,
      noDate: m.noDate,
      status,
    };
  });

  return milestones;
}

// ── Fetch application data from Digifi by tracking token ──
async function getApplicationByToken(token) {
  // If no API key, return mock data for development
  if (!DIGIFI_KEY || DIGIFI_KEY === 'your_digifi_api_key_here') {
    console.log('[DEV] No Digifi API key — returning mock data');
    if (token === 'demo' || token === 'test') {
      return { success: true, data: MOCK_DATA };
    }
    return { success: false, error: 'not_found' };
  }

  try {
    // Search for application where tracking_token matches
    // NOTE: The exact Digifi API endpoint and query format may need adjustment
    // based on their current API documentation. This is the expected pattern.
    const searchUrl = `${DIGIFI_BASE}/applications?variables.${TOKEN_VAR}=${encodeURIComponent(token)}&limit=1`;

    const response = await fetch(searchUrl, {
      headers: {
        'Authorization': `Bearer ${DIGIFI_KEY}`,
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      console.error(`Digifi API error: ${response.status} ${response.statusText}`);
      return { success: false, error: 'api_error' };
    }

    const result = await response.json();

    // Check if any applications were found
    const applications = result.data || result.applications || result;
    if (!applications || (Array.isArray(applications) && applications.length === 0)) {
      return { success: false, error: 'not_found' };
    }

    const app = Array.isArray(applications) ? applications[0] : applications;
    const vars = app.variables || {};

    // Build response
    const milestones = buildMilestones(vars);
    const completedCount = milestones.filter(m => m.status === 'done').length;

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
        milestones,
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
