# Multi-Tenant Portal Design

## Overview

A unified authentication portal that routes users to the correct tenant application (Beyaz Fırın or Leone) based on their email address and Firebase authentication.

## Architecture

### How It Works

```
User enters email + password
         ↓
Portal detects tenant from email
         ↓
Initialize correct Firebase project
         ↓
Authenticate user with tenant's Firebase
         ↓
Redirect to tenant's URL
```

### Tenant Configuration

The portal supports two tenants with separate Firebase Authentication projects:

#### **Beyaz Fırın**
- **Firebase Project**: `beyaz-firin-ai-analytics`
- **App URL**: https://beyaz-firin-mn2nr.ondigitalocean.app/
- **Email Detection**: Contains "beyaz" or "beyazfirin"
- **Users**: `arslan@metacozum.com`, `altunumut13@gmail.com`

#### **Leone Restaurant**
- **Firebase Project**: `metacozum-bi-db`
- **App URL**: https://leone-agent-2scaz.ondigitalocean.app/
- **Email Detection**: Contains "leone"
- **Users**: Any email with "leone" in it

### Tenant Detection Logic

```javascript
function getTenantFromEmail(email) {
  const emailLower = email.toLowerCase();
  
  // Check Leone first
  if (emailLower.includes('leone')) {
    return TENANTS.leone;
  }
  
  // Check Beyaz Fırın
  if (emailLower.includes('beyaz') || emailLower.includes('beyazfirin')) {
    return TENANTS.beyaz;
  }
  
  // Default to Beyaz Fırın
  return TENANTS.beyaz;
}
```

## User Experience Flow

### 1. User Visits Portal
- URL: https://tenant-portal-2grft.ondigitalocean.app/
- Sees unified login page (matching Beyaz Fırın design)

### 2. User Enters Credentials
- Email: `arslan@metacozum.com`
- Password: Their password

### 3. Portal Detects Tenant
- Scans email for tenant identifiers
- Selects correct Firebase configuration
- Shows "Beyaz Fırın kontrol ediliyor..." or "Leone Restaurant kontrol ediliyor..."

### 4. Authentication
- Initializes Firebase with tenant's configuration
- Authenticates user against correct Firebase project
- Validates credentials

### 5. Redirect to App
- **Success**: Redirects to tenant's application URL
- **Failure**: Shows error message (wrong password, user not found, etc.)

### 6. App Receives User
- User lands on tenant's application
- **Currently**: User sees login page again (needs SSO implementation)
- **Next Step**: Implement token passing to skip double login

## Current Limitations

### Double Login Issue

**Problem**: After portal authentication, users still see the app's login page.

**Why**: The tenant apps don't know the user already authenticated at the portal.

**Solution Options**:

#### **Option A: Token Passing (Recommended - Simple)**
1. Portal gets Firebase ID token after login
2. Redirect with token: `https://beyaz-firin.../path?auth_token=xyz123`
3. App reads token and validates with Firebase
4. App skips login page and shows dashboard

**Changes needed**:
- Portal: Add `await user.getIdToken()` and pass in URL
- Apps: Add token detection in `useAuth` or `App.tsx`

#### **Option B: Session Cookie (More Secure)**
1. Portal sets cross-domain cookie after login
2. Apps read cookie and validate
3. Requires `Domain=.ondigitalocean.app`

#### **Option C: Keep As-Is (No SSO)**
- Users authenticate at portal (validates credentials)
- Users authenticate again at app (establishes session)
- Simple but poor UX

## Adding New Tenants

To add a new tenant (e.g., "Restaurant X"):

### 1. Update Portal Configuration

Edit `/Users/umutaltun/Desktop/tenant-portal/index.html`:

```javascript
const TENANTS = {
  // ... existing tenants ...
  
  restaurantx: {
    name: "Restaurant X",
    url: "https://restaurantx-xxxxx.ondigitalocean.app/",
    firebaseConfig: {
      apiKey: "YOUR_API_KEY",
      authDomain: "your-project.firebaseapp.com",
      projectId: "your-project",
      storageBucket: "your-project.firebasestorage.app",
      messagingSenderId: "123456789",
      appId: "1:123456789:web:abcdef123456",
      measurementId: "G-XXXXXXXXX"
    },
    emailDomains: ["restaurantx", "restx"]  // Detection keywords
  }
};
```

### 2. Update Detection Logic (if needed)

If the default logic doesn't work, customize `getTenantFromEmail()`.

### 3. Deploy

```bash
cd /Users/umutaltun/Desktop/tenant-portal
git add index.html
git commit -m "Add Restaurant X tenant"
git push  # Auto-deploys to DigitalOcean
```

## Security Considerations

### ✅ Secure
- Firebase API keys are public (expected by Firebase)
- Authentication happens client-side with Firebase SDK
- No credentials stored in portal
- Each tenant has isolated Firebase project

### ⚠️ To Improve (Optional)
- Add rate limiting to prevent brute force attacks
- Implement CAPTCHA after failed attempts
- Use environment variables for Firebase configs (instead of hardcoded)
- Add logging/monitoring for failed login attempts

## Deployment

**Portal URL**: https://tenant-portal-2grft.ondigitalocean.app/  
**GitHub Repo**: https://github.com/altunumut24/tenant-portal  
**DigitalOcean App**: `tenant-portal` (App ID: `f5bae442-4bce-4f4d-965a-71f9635c7542`)

**Auto-Deploy**: Enabled - pushes to `main` branch trigger automatic deployment

## Cost

- **Instance**: basic-xxs ($5/month)
- **Bandwidth**: Included
- **Total**: $5/month

## Testing

### Test Beyaz Fırın Login
1. Visit: https://tenant-portal-2grft.ondigitalocean.app/
2. Email: `arslan@metacozum.com` or `altunumut13@gmail.com`
3. Password: (their actual password)
4. Expected: Redirects to https://beyaz-firin-mn2nr.ondigitalocean.app/

### Test Leone Login
1. Visit: https://tenant-portal-2grft.ondigitalocean.app/
2. Email: Any email containing "leone" (e.g., `user@leone.com`)
3. Password: (valid Leone Firebase user password)
4. Expected: Redirects to https://leone-agent-2scaz.ondigitalocean.app/

### Test Email Detection
Open browser console and check for:
```
Detected tenant: Beyaz Fırın for email: arslan@metacozum.com
Login successful. Redirecting to https://beyaz-firin-mn2nr.ondigitalocean.app/
```

## Next Steps

### Immediate (Recommended)
1. ✅ Deploy portal with multi-tenant auth (Done!)
2. ⏳ Test with real users from both tenants
3. ⏳ Implement SSO token passing to skip double login

### Future Enhancements
- Add "Forgot Password" flow per tenant
- Add user registration per tenant
- Add tenant selector (manual choice) if email detection fails
- Add user profile management
- Add audit logging
- Centralize user management across tenants (optional)

## Support

**Issue**: User can't log in  
**Check**:
1. Is the email spelled correctly?
2. Does the email match tenant detection rules?
3. Does the user exist in the correct Firebase project?
4. Check browser console for errors

**Issue**: Redirects to wrong tenant  
**Fix**: Update email detection logic in `getTenantFromEmail()`

**Issue**: Double login required  
**Fix**: Implement token passing (see "Double Login Issue" above)
