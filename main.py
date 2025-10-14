from __future__ import annotations

import os
from typing import Optional

from fastapi import FastAPI, Form
from fastapi.responses import HTMLResponse, RedirectResponse, PlainTextResponse
from pydantic import EmailStr


app: FastAPI = FastAPI(
    title="Tenant Portal",
    version="0.1.0",
    description="Minimal portal that redirects users to the appropriate tenant app.",
)


def get_target_url() -> str:
    """Return the target URL to redirect users to.

    Defaults to the Beyaz Fırın deployment. Can be overridden via the
    TARGET_URL environment variable during deployment.
    """
    default_url: str = "https://beyaz-firin-mn2nr.ondigitalocean.app/"
    target_url: str = os.getenv("TARGET_URL", default_url).strip()
    return target_url


@app.get("/", response_class=HTMLResponse)
def index() -> str:
    """Serve a minimal login page that posts to /resolve.

    The credentials are not validated here; the endpoint simply redirects
    to the configured tenant URL for now.
    """
    html: str = """
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Login | Tenant Portal</title>
    <style>
      body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; margin: 0; padding: 0; background: #f7f7f8; }
      .container { max-width: 420px; margin: 10vh auto; background: #fff; border: 1px solid #e5e7eb; border-radius: 12px; box-shadow: 0 8px 30px rgba(0,0,0,0.06); }
      .header { padding: 20px 24px; border-bottom: 1px solid #f1f5f9; font-weight: 600; font-size: 18px; }
      .content { padding: 24px; }
      label { display: block; margin-bottom: 6px; color: #374151; font-size: 14px; }
      input { width: 100%; padding: 10px 12px; border: 1px solid #e5e7eb; border-radius: 8px; font-size: 14px; box-sizing: border-box; }
      .field { margin-bottom: 16px; }
      button { width: 100%; background: #111827; color: #fff; border: 0; padding: 10px 14px; border-radius: 8px; font-weight: 600; cursor: pointer; }
      button:hover { background: #0b1220; }
      .footer { padding: 16px 24px; color: #6b7280; font-size: 12px; border-top: 1px solid #f1f5f9; text-align: center; }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="header">Tenant Portal</div>
      <div class="content">
        <form method="post" action="/resolve" novalidate>
          <div class="field">
            <label for="email">Email</label>
            <input id="email" name="email" type="email" placeholder="you@example.com" required />
          </div>
          <div class="field">
            <label for="password">Password</label>
            <input id="password" name="password" type="password" placeholder="••••••••" required />
          </div>
          <button type="submit">Continue</button>
        </form>
      </div>
      <div class="footer">You will be redirected to the appropriate tenant application.</div>
    </div>
  </body>
</html>
    """
    return html


@app.post("/resolve")
def resolve(email: Optional[EmailStr] = Form(None), password: Optional[str] = Form(None)) -> RedirectResponse:
    """Resolve the tenant based on credentials and redirect.

    Currently this ignores credentials and unconditionally redirects to the
    Beyaz Fırın application (or TARGET_URL if provided as an environment var).
    """
    return RedirectResponse(url=get_target_url(), status_code=302)


@app.get("/healthz")
def healthz() -> PlainTextResponse:
    """Liveness/readiness probe endpoint."""
    return PlainTextResponse(content="ok", status_code=200)

