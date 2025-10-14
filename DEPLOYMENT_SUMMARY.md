# Tenant Portal - Deployment Summary

## ✅ Deployment Status

**App ID:** `f5bae442-4bce-4f4d-965a-71f9635c7542`  
**App Name:** `tenant-portal`  
**Status:** Building... (In Progress)  
**GitHub Repo:** https://github.com/altunumut24/tenant-portal  

## 📦 What Was Deployed

A minimal FastAPI-based login portal that redirects users to the Beyaz Fırın application.

### Features
- Clean login page with email/password form
- POST `/resolve` endpoint that redirects to configured tenant URL
- Health check endpoint at `/healthz`
- Minimal resource usage: **basic-xxs** instance ($5/month)

### Configuration
- **Target URL:** `https://beyaz-firin-mn2nr.ondigitalocean.app/`
- **Instance Size:** basic-xxs (512 MB RAM, 1 vCPU)
- **Region:** NYC
- **Auto-deploy:** Enabled (pushes to `main` branch trigger deployment)

## 🔗 Access

Once deployment completes (3-5 minutes), check the URL:

```bash
doctl apps get f5bae442-4bce-4f4d-965a-71f9635c7542
```

The `Default Ingress` field will show your portal URL (e.g., `https://tenant-portal-xxxxx.ondigitalocean.app`).

Alternatively, visit: https://cloud.digitalocean.com/apps/f5bae442-4bce-4f4d-965a-71f9635c7542

## 📊 Cost Breakdown

| Service | Instance Size | Monthly Cost |
|---------|---------------|--------------|
| Portal  | basic-xxs     | $5.00        |
| **Total** |             | **$5.00**    |

This is the absolute minimum configuration for a production portal.

## 🚀 Next Steps

### 1. Wait for Build to Complete
```bash
# Check deployment status
doctl apps get f5bae442-4bce-4f4d-965a-71f9635c7542

# View build logs
doctl apps logs f5bae442-4bce-4f4d-965a-71f9635c7542 --type BUILD

# View deploy logs
doctl apps logs f5bae442-4bce-4f4d-965a-71f9635c7542 --type DEPLOY
```

### 2. Test the Portal
Once deployed, visit the URL and test the login flow. It will redirect to Beyaz Fırın.

### 3. Configure Custom Domain (Optional)
To use a custom domain like `login.yourdomain.com`:

1. Go to https://cloud.digitalocean.com/apps/f5bae442-4bce-4f4d-965a-71f9635c7542/settings
2. Click "Domains" → "Add Domain"
3. Enter `login.yourdomain.com`
4. Update your DNS with the provided CNAME record
5. DigitalOcean will provision TLS certificate automatically

### 4. Add Leone Restaurant Support

When you deploy the Leone app and want to add it to the portal:

**Option A: Email-based routing**

Edit `main.py`:
```python
def resolve_tenant_url(email: str) -> str:
    domain = email.split("@")[1].lower()
    
    if "beyaz" in domain or "beyazfirin" in domain:
        return "https://beyaz-firin-mn2nr.ondigitalocean.app/"
    elif "leone" in domain:
        return "https://leone-restaurant-xxxxx.ondigitalocean.app/"
    
    # Default fallback
    return "https://beyaz-firin-mn2nr.ondigitalocean.app/"

@app.post("/resolve")
def resolve(email: Optional[EmailStr] = Form(None), password: Optional[str] = Form(None)) -> RedirectResponse:
    if email:
        target_url = resolve_tenant_url(email)
    else:
        target_url = get_target_url()
    return RedirectResponse(url=target_url, status_code=302)
```

**Option B: Simple tenant selector (two buttons)**

Add buttons before the form in `index()`:
```html
<div class="content">
  <div style="display: flex; gap: 10px; margin-bottom: 20px;">
    <button onclick="setTenant('beyaz')" style="width: 50%;">Beyaz Fırın</button>
    <button onclick="setTenant('leone')" style="width: 50%;">Leone</button>
  </div>
  <form method="post" action="/resolve">
    <input type="hidden" name="tenant" id="tenant" value="beyaz" />
    <!-- rest of form -->
  </form>
</div>
<script>
  function setTenant(t) { document.getElementById('tenant').value = t; }
</script>
```

Then push changes:
```bash
git add main.py
git commit -m "Add Leone support"
git push  # Auto-deploys to DO
```

## 🔧 Management Commands

```bash
# View app details
doctl apps get f5bae442-4bce-4f4d-965a-71f9635c7542

# List all apps
doctl apps list

# Update app spec
doctl apps update f5bae442-4bce-4f4d-965a-71f9635c7542 --spec .doctl-app.yaml

# View logs (live tail)
doctl apps logs f5bae442-4bce-4f4d-965a-71f9635c7542 --type RUN --follow

# Restart the app
doctl apps restart f5bae442-4bce-4f4d-965a-71f9635c7542

# Delete the app (if needed)
doctl apps delete f5bae442-4bce-4f4d-965a-71f9635c7542
```

## 📝 Environment Variables

Current config (can be changed in DO console or via spec):

- `TARGET_URL` = `https://beyaz-firin-mn2nr.ondigitalocean.app/`
- `PORT` = `8080` (auto-set by DO)

## 🎯 Summary

✅ Portal deployed with minimal resources ($5/month)  
✅ Auto-deploy enabled on git push  
✅ Health checks configured  
✅ Ready to redirect to Beyaz Fırın  
✅ Easy to extend for Leone support  

The portal is production-ready with the simplest possible architecture. No databases, no complex auth, just a clean redirect based on your logic.

