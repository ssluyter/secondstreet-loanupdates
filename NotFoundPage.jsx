import React from 'react';

export default function NotFoundPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-[#F5F6FA] px-6">
      <div className="text-center max-w-md">
        <div className="w-16 h-16 rounded-2xl bg-navy/5 flex items-center justify-center mx-auto mb-5">
          <svg viewBox="0 0 24 24" fill="none" stroke="#161E5B" strokeWidth="1.5" strokeLinecap="round" className="w-8 h-8">
            <path d="M3 12h18M12 3v18" />
            <circle cx="12" cy="12" r="10" />
          </svg>
        </div>
        <h1 className="font-serif text-2xl text-navy mb-2">Second Street</h1>
        <p className="text-sm text-gray-500 leading-relaxed mb-6">
          This page requires a valid tracking link. If you received a link from your loan officer, please try clicking it again or copying the full URL.
        </p>
        <p className="text-xs text-gray-400">
          Need help? Contact us at{' '}
          <a href="mailto:info@mysecondstreet.com" className="text-ss-blue hover:text-ss-blue-hover">
            info@mysecondstreet.com
          </a>
          {' '}&bull;{' '}
          <a href="tel:+18007001002" className="text-ss-blue hover:text-ss-blue-hover">
            +1 (800) 700-1002
          </a>
        </p>
      </div>
    </div>
  );
}
