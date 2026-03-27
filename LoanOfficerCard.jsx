import React from 'react';

export default function LoanOfficerCard({ name, email, phone }) {
  if (!name) return null;

  const initials = name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase();

  return (
    <div className="bg-white rounded-xl border border-ss-border p-5 mt-4 opacity-0 animate-fade-in-up stagger-6">
      <div className="text-[11px] font-semibold text-gray-400 uppercase tracking-wider mb-3">Your loan officer</div>
      <div className="flex items-center gap-3">
        <div className="w-11 h-11 rounded-full bg-navy flex items-center justify-center text-white font-semibold text-sm flex-shrink-0">
          {initials}
        </div>
        <div className="min-w-0">
          <div className="text-[15px] font-semibold text-navy">{name}</div>
          <div className="flex flex-wrap gap-x-4 gap-y-0.5 mt-0.5">
            {email && (
              <a href={`mailto:${email}`} className="text-[12px] text-ss-blue hover:text-ss-blue-hover transition-colors">
                {email}
              </a>
            )}
            {phone && (
              <a href={`tel:${phone}`} className="text-[12px] text-ss-blue hover:text-ss-blue-hover transition-colors">
                {phone}
              </a>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
