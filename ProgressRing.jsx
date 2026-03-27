import React, { useEffect, useState } from 'react';

export default function ProgressRing({ completed, total }) {
  const [offset, setOffset] = useState(207.3);
  const pct = Math.round((completed / total) * 100);
  const circumference = 207.3;

  useEffect(() => {
    const timer = setTimeout(() => {
      setOffset(circumference - (circumference * pct / 100));
    }, 300);
    return () => clearTimeout(timer);
  }, [pct]);

  return (
    <div className="relative w-[88px] h-[88px] flex-shrink-0">
      <svg viewBox="0 0 80 80" className="-rotate-90">
        <circle cx="40" cy="40" r="33" fill="none" stroke="rgba(255,255,255,0.15)" strokeWidth="5" />
        <circle
          cx="40" cy="40" r="33"
          fill="none" stroke="#fff" strokeWidth="5" strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          style={{ transition: 'stroke-dashoffset 1.2s ease' }}
        />
      </svg>
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <span className="text-[22px] font-bold text-white leading-none">{pct}%</span>
        <span className="text-[9px] text-white/60 uppercase tracking-wider mt-0.5">Complete</span>
      </div>
    </div>
  );
}
