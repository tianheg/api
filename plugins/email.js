import fp from 'fastify-plugin';
import nodemailer from 'nodemailer';

export default fp(async (app, _) => {
  // Get email configuration from environment variables using updated variable names
  const { 
    EMAIL_SMTP_HOST,
    EMAIL_SMTP_PORT, 
    EMAIL_SMTP_USER, 
    EMAIL_SMTP_PASS, 
    EMAIL_FROM 
  } = app.secrets;
  
  // Create a testing account if credentials not provided
  let testAccount = null;
  let transporter;
  
  if (!EMAIL_SMTP_HOST || !EMAIL_SMTP_USER) {
    // Create testing account for development
    app.log.info('No SMTP credentials found, creating test account');
    testAccount = await nodemailer.createTestAccount();
    
    transporter = nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      secure: false,
      auth: {
        user: testAccount.user,
        pass: testAccount.pass,
      },
    });
    
    app.log.info(`Test email account created: ${testAccount.user}`);
  } else {
    // Use configured SMTP server
    transporter = nodemailer.createTransport({
      host: EMAIL_SMTP_HOST,
      port: EMAIL_SMTP_PORT || 587,
      secure: EMAIL_SMTP_PORT === '465',
      auth: {
        user: EMAIL_SMTP_USER,
        pass: EMAIL_SMTP_PASS,
      },
    });
  }
  
  // Add email service to fastify instance
  app.decorate('email', {
    async sendMagicLink(to, magicLink) {
      const info = await transporter.sendMail({
        from: EMAIL_FROM || '"Magic Link Service" <noreply@example.com>',
        to,
        subject: 'Your Magic Login Link',
        text: `Click this link to log in: ${magicLink}`,
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2>Login to Your Account</h2>
            <p>Click the button below to log in:</p>
            <p style="margin: 20px 0;">
              <a href="${magicLink}" 
                style="background-color: #4CAF50; color: white; padding: 10px 20px; 
                text-decoration: none; border-radius: 4px; display: inline-block;">
                Log In
              </a>
            </p>
            <p>Or copy and paste this link in your browser:</p>
            <p>${magicLink}</p>
            <p>This link will expire in 15 minutes.</p>
          </div>
        `,
      });
      
      // For ethereal test accounts, provide the preview URL
      if (testAccount) {
        app.log.info(`Preview URL: ${nodemailer.getTestMessageUrl(info)}`);
      }
      
      return info;
    }
  });
});
