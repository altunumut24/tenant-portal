# Tenant Portal

Minimal login portal that redirects users to the appropriate tenant application (Beyaz Fırın, Leone, etc.).

## Features

- Simple email/password form
- Redirects to configured tenant URL
- Minimal resource usage (basic-xxs instance on DigitalOcean)
- Health check endpoint at `/healthz`

## Local Development

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the server
uvicorn main:app --reload --port 8080

# Open browser
open http://localhost:8080
```

## Deploy to DigitalOcean App Platform

### Option 1: Using doctl CLI (Recommended)

1. Install doctl:
   ```bash
   # macOS
   brew install doctl
   
   # Authenticate
   doctl auth init
   ```

2. Push code to GitHub:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/YOUR_USERNAME/tenant-portal.git
   git push -u origin main
   ```

3. Update `.doctl-app.yaml` with your GitHub repo details

4. Deploy:
   ```bash
   # Create new app
   doctl apps create --spec .doctl-app.yaml
   
   # Or update existing app
   doctl apps update <APP_ID> --spec .doctl-app.yaml
   ```

### Option 2: Using DigitalOcean Console

1. Go to [DigitalOcean Apps](https://cloud.digitalocean.com/apps)
2. Click "Create App"
3. Connect your GitHub repository
4. Select this repository and branch
5. Configure:
   - Build command: (leave empty, using Dockerfile)
   - Run command: (leave empty, using Dockerfile CMD)
   - HTTP port: 8080
   - Instance size: Basic (512 MB RAM, $5/mo)
6. Add environment variable:
   - `TARGET_URL` = `https://beyaz-firin-mn2nr.ondigitalocean.app/`
7. Click "Create Resources"

## Configuration

Environment variables:

- `TARGET_URL` - The URL to redirect users to after login (default: Beyaz Fırın app)
- `PORT` - Server port (default: 8080, automatically set by DO App Platform)

## Cost

- **DigitalOcean App Platform**: ~$5/month (basic-xxs instance)
- **Total**: $5/month

This is the minimal configuration for a production-ready portal.

## Future Enhancements

When you're ready to add Leone restaurant:

1. Add tenant resolution logic in `main.py`:
   ```python
   def resolve_tenant_url(email: str) -> str:
       domain = email.split("@")[1].lower()
       if "beyaz" in domain:
           return "https://beyaz-firin-mn2nr.ondigitalocean.app/"
       elif "leone" in domain:
           return "https://leone-restaurant-xxx.ondigitalocean.app/"
       return "https://beyaz-firin-mn2nr.ondigitalocean.app/"  # default
   ```

2. Or add a simple tenant selector (two buttons) before the login form

