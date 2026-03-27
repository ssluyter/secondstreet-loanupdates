# Second Street — Loan Status Tracker

A branded, read-only loan status portal for third parties (agents, attorneys, escrow officers) to track loan progress via a unique shareable link.

## How It Works

1. Your team creates a `tracking_token` variable on a loan file in Digifi
2. They share `status.mysecondstreet.com/track/{token}` with the agent/attorney
3. The agent clicks the link and sees a real-time pizza tracker with milestone dates
4. To revoke access, clear the `tracking_token` variable in Digifi

## Tech Stack

- **Backend:** Node.js + Express
- **Frontend:** React + Vite + Tailwind CSS
- **Data:** Digifi API (read-only)
- **Hosting:** Render
- **Fonts:** Montserrat + DM Serif Display

## Prerequisites

Before deploying, you need:

1. **Digifi API key** with application read access
   - Go to Digifi → General Settings → Developers → API Keys
   - Create a key with read permissions for applications
2. **A `tracking_token` variable in Digifi**
   - Go to Lending Setup → Variables → Add Variable
   - Name: `Tracking Token`, System name: `tracking_token`, Type: Text
3. **Loan officer variable names** — update these in `server/digifi.js`:
   - `lo_name` → your actual LO name variable system name
   - `lo_email` → your actual LO email variable system name
   - `lo_phone` → your actual LO phone variable system name

## Local Development

```bash
# 1. Clone and install
git clone <your-repo-url>
cd ss-status-tracker
npm run install:all

# 2. Configure environment
cp .env.example .env
# Edit .env with your Digifi API key

# 3. Run development servers
npm run dev
# Frontend: http://localhost:5173
# Backend:  http://localhost:3001

# 4. Test with mock data
# Visit: http://localhost:5173/track/demo
```

## Deploy to Render

### Option A: Using render.yaml (recommended)

1. Push this repo to GitHub
2. Go to [render.com](https://render.com) → New → Blueprint
3. Connect your GitHub repo
4. Render will read `render.yaml` and configure everything
5. Add your `DIGIFI_API_KEY` in Render's environment variables
6. Deploy

### Option B: Manual setup

1. Push this repo to GitHub
2. Go to Render → New → Web Service
3. Connect your GitHub repo
4. Settings:
   - **Build command:** `npm run install:all && npm run build`
   - **Start command:** `npm start`
   - **Environment:** Node
5. Add environment variables:
   - `NODE_ENV` = `production`
   - `DIGIFI_API_BASE_URL` = `https://api.digifi.io/v1`
   - `DIGIFI_API_KEY` = your key
   - `DIGIFI_TRACKING_TOKEN_VAR` = `tracking_token`
   - `CLIENT_URL` = `https://status.mysecondstreet.com`

### Custom Domain Setup

1. In Render → your service → Settings → Custom Domains
2. Add `status.mysecondstreet.com`
3. In your DNS provider, add a CNAME record:
   - **Host:** `status`
   - **Value:** `ss-status-tracker.onrender.com` (Render will provide the exact value)
4. Wait for SSL certificate to provision (automatic via Let's Encrypt)

## Variable Mapping Reference

### Confirmed Variables (in Digifi)
| Milestone | Digifi Variable |
|-----------|----------------|
| Pre-approval issued | `pal_delivery_date` |
| Appraisal ordered | `property_appraisal_request_date` |
| Appraisal received | `property_appraisal_delivered_date` |
| Due diligence ordered | `property_due_diligence_ordered_date` |
| Due diligence cleared | `property_due_diligence_delivered_date` |
| Open escrow | `trust_and_escrow_request_date` |
| Escrow open date | `trust_and_escrow_received_date` |
| Property address | `borrower_cr_subject_address_tracker` |

### Placeholder Variables (create in Digifi)
| Milestone | Suggested Variable |
|-----------|-------------------|
| Clear to close | `clear_to_close_date` |
| Closing scheduled | `closing_scheduled_date` |
| Funded | `funded_date` |
| Estimated closing | `estimated_closing_date` |
| Tracking token | `tracking_token` |

## Project Structure

```
ss-status-tracker/
├── .env.example           ← Environment template
├── .gitignore
├── render.yaml            ← Render deployment config
├── package.json           ← Root scripts
├── server/
│   ├── package.json
│   ├── index.js           ← Express server
│   └── digifi.js          ← Digifi API client + variable mapping
└── client/
    ├── package.json
    ├── vite.config.js
    ├── tailwind.config.js
    ├── index.html
    └── src/
        ├── main.jsx
        ├── index.css
        ├── components/
        │   ├── ProgressRing.jsx
        │   ├── MilestoneCard.jsx
        │   ├── MilestoneIcons.jsx
        │   └── LoanOfficerCard.jsx
        └── pages/
            ├── TrackerPage.jsx
            └── NotFoundPage.jsx
```

## Security Notes

- Tracking tokens should be cryptographically random (use `crypto.randomBytes(16).toString('hex')`)
- The API endpoint is rate-limited (30 requests/minute per IP)
- No sensitive data (SSN, financials) is exposed through the tracker
- Tokens are validated for format before any API calls
- To revoke access, clear the tracking_token in Digifi
