# 📧 Enveloop Email Setup for Proofie

## Overview
Proofie is now configured to use Enveloop for email delivery in production. This guide will help you set up email functionality for your deployed app.

## 🚀 Quick Setup

### 1. Create Enveloop Account
1. Go to [https://enveloop.com](https://enveloop.com)
2. Sign up for a free account
3. Verify your email address

### 2. Get Your API Key
1. Log into your Enveloop dashboard
2. Navigate to **Settings** → **API Keys**
3. Create a new API key
4. Copy the API key (keep it secure!)

### 3. Create Email Template (Optional)
1. In your Enveloop dashboard, go to **Templates**
2. Create a new template for transactional emails
3. Copy the template ID for configuration

### 4. Configure Your Fly.io App
```bash
# Set your Enveloop API key
fly secrets set ENVELOOP_API_KEY=your_enveloop_api_key_here

# Optional: Set default template ID
fly secrets set ENVELOOP_TEMPLATE_ID=your_template_id_here

# Redeploy to pick up the new configuration
fly deploy
```

## 📋 Environment Variables

Your Proofie app expects these environment variables:

| Variable | Required | Description |
|----------|----------|-------------|
| `ENVELOOP_API_KEY` | ✅ Yes | Your Enveloop API key from the dashboard |
| `ENVELOOP_TEMPLATE_ID` | ❌ Optional | Default template ID for emails |

## 🧪 Testing Email Delivery

### Local Development
```bash
# Set environment variables
export ENVELOOP_API_KEY=your_api_key
export ENVELOOP_TEMPLATE_ID=your_template_id

# Start your app
mix phx.server
```

### Production Testing
1. Deploy your app with the environment variables set
2. Register a new user account
3. Check that confirmation emails are sent
4. Test password reset functionality

## 📝 Email Templates

### Default Behavior
If no template ID is provided, Proofie will send emails with:
- Subject from the email
- HTML body from the email content
- Text body as fallback

### Custom Templates
To use Enveloop templates:
1. Create templates in your Enveloop dashboard
2. Set `ENVELOOP_TEMPLATE_ID` environment variable
3. Use template variables in your Phoenix emails

### Template Variables
The adapter automatically includes:
- `subject` - Email subject line
- `html_body` - HTML email content
- `text_body` - Plain text email content

## 🔧 Troubleshooting

### Common Issues

**API Key Not Working**
- Verify the API key is correctly set in Fly.io secrets
- Check that the key hasn't been regenerated in Enveloop
- Ensure no extra spaces in the environment variable

**Emails Not Sending**
- Check your app logs: `fly logs`
- Verify your sender email is configured in Enveloop
- Ensure your domain is verified (for custom domains)

**Template Not Found**
- Verify the template ID exists in your Enveloop account
- Check that the template is published/active
- Try removing the template ID to use default behavior

### Debug Commands
```bash
# Check current secrets
fly secrets list

# View application logs
fly logs --app your-app-name

# SSH into app to test
fly ssh console --app your-app-name
```

## 🎯 Next Steps

1. **Set up domain verification** in Enveloop for better deliverability
2. **Create branded email templates** for password resets and confirmations
3. **Monitor email delivery** through the Enveloop dashboard
4. **Set up webhooks** for delivery notifications (optional)

## 📞 Support

- **Enveloop Docs**: [https://docs.enveloop.com](https://docs.enveloop.com)
- **Fly.io Docs**: [https://fly.io/docs](https://fly.io/docs)
- **Phoenix Mailer**: [https://hexdocs.pm/swoosh](https://hexdocs.pm/swoosh)

Your Proofie app is now ready for production email delivery! 🎉

