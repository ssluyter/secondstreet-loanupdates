import React from 'react';

const icons = [
  // Step 1: Application received (clock)
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M10 3v7l4 3"/><circle cx="10" cy="10" r="7"/></svg>,
  // Step 2: Submitted to UW (plus/submit)
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M4 10h12M10 4v12"/><rect x="3" y="3" width="14" height="14" rx="3"/></svg>,
  // Step 3: Pre-approval (checkmark circle)
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M6 10l3 3 5-6"/><circle cx="10" cy="10" r="7"/></svg>,
  // Step 4: Appraisal ordered (house/value)
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M4 14l4-8h4l4 8M6 11h8"/></svg>,
  // Step 5: Appraisal received (document/map)
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M3 16V6l7-3 7 3v10l-7 3z"/><path d="M10 3v16"/></svg>,
  // Step 6: DD ordered (document)
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M5 4h10a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2V6a2 2 0 012-2z"/><path d="M7 8h6M7 11h4"/></svg>,
  // Step 7: DD cleared (checkbox)
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M6 10l3 3 5-6"/><rect x="3" y="3" width="14" height="14" rx="2"/></svg>,
  // Step 8: Open escrow (key/open)
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M10 3v4M6 5l2 3M14 5l-2 3"/><rect x="4" y="10" width="12" height="6" rx="2"/></svg>,
  // Step 9: Escrow open date (clock)
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><circle cx="10" cy="10" r="7"/><path d="M10 6v4h3"/></svg>,
  // Step 10: Clear to close (checkmark circle)
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M6 10l3 3 5-6"/><circle cx="10" cy="10" r="7"/></svg>,
  // Step 11: Closing scheduled (calendar)
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M4 6h12M4 10h12M4 14h12"/></svg>,
  // Step 12: Funded (star)
  <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round"><path d="M10 3l2 4 5 1-4 3 1 5-4-2-4 2 1-5-4-3 5-1z"/></svg>,
];

export default function MilestoneIcon({ step }) {
  return icons[step - 1] || icons[0];
}
