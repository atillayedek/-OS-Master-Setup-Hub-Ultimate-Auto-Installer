# Backend API Contract — Authentication & Student Verification

This is the contract the iOS client in `KampusAgi-iOS/` assumes for the
modules built so far. It is **not implemented** in this repository (see
`PHASE1_AUDIT.md` §5) — it specifies what a Cloud Functions/TypeScript
backend (per brief §2) must provide.

All endpoints are relative to `API_BASE_URL` (per environment, see
`KampusAgi-iOS/Configs/*.xcconfig`). Every endpoint except none of these
requires `Authorization: Bearer <Firebase ID token>` — the backend must
verify that token server-side (Firebase Admin SDK) on every request; it must
never trust a client-supplied UID, university ID, or account status.

## Authorization rules (server-authoritative, §10, §11, §20)

- The backend resolves the authenticated user from the verified Firebase
  UID, not from any request body/header field the client sends.
- Every endpoint below except `/v1/auth/sync` must reject (403) a caller
  whose resolved `account_status` is not `APPROVED`, once such endpoints
  exist (community, matchmaking, chat — out of scope for this pass, but the
  rule already applies to nothing implemented yet since verification's own
  endpoints must remain reachable by pending/rejected users).
- `/v1/verification/*` endpoints must remain reachable regardless of
  `account_status` (a pending/rejected user needs them to check status or
  resubmit).

## POST /v1/auth/sync

Called after every sign-in, sign-up, and app-launch session restore.
**Idempotent** (§14) — must not create a duplicate profile for a UID that
already exists, and must not overwrite `account_status`, `university_id`,
or `department` on repeat calls.

Request:
```json
{ "full_name": "Ada Lovelace" }
```
`full_name` is optional; when present, only used the *first* time a UID is
seen (i.e. on the row-creating call). Ignored on every subsequent call.

Response `200`:
```json
{
  "id": "firebase-uid",
  "email": "ada@example.edu.tr",
  "full_name": "Ada Lovelace",
  "account_status": "PENDING_DOCUMENT",
  "university_id": null,
  "department": null,
  "rejection_reason": null
}
```

`account_status` is one of `PENDING_DOCUMENT`, `PENDING_REVIEW`,
`APPROVED`, `REJECTED`, `SUSPENDED`, `DELETED` (§10).

## GET /v1/universities?query={text}

Returns the backend-sourced university list (§17) — the client has no
hardcoded list. Empty/omitted `query` returns the full list (used to
populate the client's offline cache).

Response `200`:
```json
{
  "universities": [
    {
      "id": "8f14e...uuid",
      "name": "ODTÜ",
      "official_name": "Orta Doğu Teknik Üniversitesi",
      "domain": "metu.edu.tr",
      "city": "Ankara",
      "type": "state"
    }
  ]
}
```
`type` is one of `state`, `private`, `foundation`.

## POST /v1/verification/apply

`multipart/form-data`:
- `university_id` (text, UUID) — the university to associate; the client
  never claims this is fixed, but the backend should still sanity-check the
  ID exists.
- `department` (text, 2–150 chars after trimming)
- `document` (file, `application/pdf`, ≤ 10 MB)

Server-side validation (§7 — the client's own PDF-magic-byte + size check is
a UX convenience only, never trusted as final):
- Re-verify the PDF magic bytes and that the file parses as a real PDF.
- Reject anything that isn't a genuine PDF (screenshots re-saved as `.pdf`,
  corrupted files) — this must happen server-side since a modified client
  could send anything.
- Enforce the 10 MB limit again.
- Store the document (Firebase Storage or equivalent) and move
  `account_status` to `PENDING_REVIEW`.

Response `200`:
```json
{ "account_status": "PENDING_REVIEW", "rejection_reason": null }
```

Error responses: `400` (invalid department / not a PDF / too large — body
should carry a machine-readable reason so future client versions can show a
precise message), `409` if an application is already pending.

## POST /v1/verification/resubmit

Same `document` field and validation as `/apply`, no university/department
fields (those don't change on resubmission). Only valid when
`account_status == REJECTED`. Moves status back to `PENDING_REVIEW`.

Response: same shape as `/apply`.

## GET /v1/verification/status

Response `200`:
```json
{ "account_status": "PENDING_REVIEW", "rejection_reason": null }
```
When `account_status == REJECTED`, `rejection_reason` should be a short,
human-readable (Turkish) explanation an admin entered — the client shows it
verbatim on the Rejected screen (§13).

## Push notification on decision (§11, §31)

When an admin approves or rejects an application, the backend should send an
FCM push (`Verification Approved` / `Verification Rejected`, §31) to every
registered device token for that UID. Not implemented client-side yet —
FCM token registration is a follow-up phase (Notifications feature).

## Out of scope for this contract

Communities, Matchmaking, Chat, Gemini AI processing/embeddings, StoreKit
receipt verification, trust score, rate limiting specifics — all described
in the full brief (§15–§31, §40–§49) but not needed by the client code in
this pass. Build them against the same auth model (verified Firebase UID,
server-resolved `account_status`, never a client-supplied claim) when their
turn comes.
