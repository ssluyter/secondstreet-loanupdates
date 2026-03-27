import React from 'react';
import MilestoneIcon from './MilestoneIcons';

export default function MilestoneCard({ milestone, index }) {
  const { step, label, date, noDate, status } = milestone;

  const cardClasses = {
    done: 'bg-white border-[1.5px] border-ss-blue/20 shadow-sm hover:border-ss-blue/40 hover:shadow-md hover:-translate-y-0.5 transition-all duration-250',
    active: 'bg-white border-2 border-ss-blue shadow-[0_0_0_4px_rgba(31,88,251,0.1),0_2px_12px_rgba(22,30,91,0.06)]',
    pending: 'bg-ss-bg border-[1.5px] border-dashed border-ss-border opacity-55',
  };

  const iconBg = {
    done: 'bg-ss-blue/[0.08] text-ss-blue',
    active: 'bg-ss-blue/[0.12] text-ss-blue',
    pending: 'bg-gray-100 text-gray-300',
  };

  return (
    <div
      className={`rounded-xl p-4 relative cursor-default opacity-0 animate-fade-in-up stagger-${step} ${cardClasses[status]}`}
    >
      {/* Icon */}
      <div className={`w-8 h-8 rounded-lg flex items-center justify-center mb-2.5 ${iconBg[status]}`}>
        <div className="w-[18px] h-[18px]">
          <MilestoneIcon step={step} />
        </div>
      </div>

      {/* Check badge */}
      {status === 'done' && (
        <div className="absolute top-3 right-3 w-5 h-5 rounded-full bg-ss-blue flex items-center justify-center">
          <svg viewBox="0 0 12 12" fill="none" stroke="#fff" strokeWidth="2" strokeLinecap="round" className="w-[11px] h-[11px]">
            <path d="M2.5 6l2.5 2.5 4.5-5" />
          </svg>
        </div>
      )}

      {/* Step label */}
      <div className={`text-[10px] font-semibold uppercase tracking-wider mb-1 ${status === 'pending' ? 'text-gray-300' : 'text-ss-blue'}`}>
        Step {step}
      </div>

      {/* Milestone name */}
      <div className={`text-[13px] leading-snug mb-2 ${status === 'pending' ? 'text-gray-400 font-medium' : 'text-navy font-semibold'}`}>
        {label}
      </div>

      {/* Status line */}
      {status === 'done' && (
        noDate || !date
          ? <div className="text-[11px] font-semibold text-ss-green">Complete</div>
          : <div className="text-[11px] font-semibold text-ss-blue">{date}</div>
      )}
      {status === 'active' && (
        <div className="text-[11px] font-semibold text-ss-blue italic flex items-center gap-1.5">
          <span className="inline-block w-2 h-2 rounded-full bg-ss-blue animate-pulse-dot" />
          In progress
        </div>
      )}
      {status === 'pending' && (
        <div className="text-[11px] text-gray-300 italic">Pending</div>
      )}
    </div>
  );
}
