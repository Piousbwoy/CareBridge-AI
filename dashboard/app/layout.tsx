import React from 'react';

export const metadata = {
  title: 'CareBridge AI - Supervisor Dashboard',
  description: 'CHPS Regional Supervisor Monitoring Dashboard for Northern Ghana',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <head>
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@600;700&display=swap"
          rel="stylesheet"
        />
        <style>{`
          body {
            font-family: 'Inter', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f8f9fa;
            color: #1e293b;
          }
          h1, h2, h3, h4 {
            font-family: 'Outfit', sans-serif;
          }
        `}</style>
      </head>
      <body>{children}</body>
    </html>
  );
}
