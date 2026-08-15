import json
import os
import urllib.request
import urllib.error

from dotenv import load_dotenv

load_dotenv()

BREVO_API_KEY = os.getenv("BREVO_API_KEY")
BREVO_SENDER_EMAIL = os.getenv("BREVO_SENDER_EMAIL")
BREVO_SENDER_NAME = os.getenv("BREVO_SENDER_NAME", "FinPilotAI")


async def send_otp_email(
    recipient_email: str,
    otp: str,
):
    if not BREVO_API_KEY:
        raise RuntimeError("BREVO_API_KEY is not configured")

    if not BREVO_SENDER_EMAIL:
        raise RuntimeError("BREVO_SENDER_EMAIL is not configured")

    url = "https://api.brevo.com/v3/smtp/email"

    payload = {
        "sender": {
            "name": BREVO_SENDER_NAME,
            "email": BREVO_SENDER_EMAIL,
        },
        "to": [
            {
                "email": recipient_email,
            }
        ],
        "subject": "FinPilotAI Email Verification OTP",
        "htmlContent": f"""
        <html>
          <body>
            <h2>FinPilotAI Email Verification</h2>

            <p>Your verification OTP is:</p>

            <h1>{otp}</h1>

            <p>This OTP will expire in 5 minutes.</p>

            <p>If you did not request this OTP, please ignore this email.</p>

            <br>

            <p>Regards,<br>
            FinPilotAI Team</p>
          </body>
        </html>
        """,
    }

    data = json.dumps(payload).encode("utf-8")

    request = urllib.request.Request(
        url,
        data=data,
        method="POST",
        headers={
            "accept": "application/json",
            "api-key": BREVO_API_KEY,
            "content-type": "application/json",
        },
    )

    try:
        with urllib.request.urlopen(request, timeout=15) as response:
            response_body = response.read().decode("utf-8")

            return {
                "success": True,
                "response": response_body,
            }

    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8")

        raise RuntimeError(
            f"Brevo API error {e.code}: {error_body}"
        )

    except urllib.error.URLError as e:
        raise RuntimeError(
            f"Unable to connect to Brevo: {e}"
        )