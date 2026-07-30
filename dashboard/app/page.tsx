'use client';

import React, { useState } from 'react';

export default function SupervisorDashboard() {
  const [filterZone, setFilterZone] = useState('Bole CHPS Zone');
  const [activeTier, setActiveTier] = useState('ALL');

  const households = [
    {
      id: 'H-10041',
      name: 'Akua Serwaa',
      zone: 'Bole CHPS Zone',
      chw: 'Ama Akosua (CHO)',
      tier: 'URGENT',
      reasons: ['MUAC 10.5cm — SAM', 'Fast breathing (62/min) in young infant'],
      overdueDays: 21,
      lastSync: '10:25 AM Today',
      referralStatus: 'Queued via SMS',
    },
    {
      id: 'H-10042',
      name: "Abena Gyamfi's Baby",
      zone: 'Bole CHPS Zone',
      chw: 'Ama Akosua (CHO)',
      tier: 'WATCH',
      reasons: ['MUAC 12.0cm — MAM'],
      overdueDays: 14,
      lastSync: '10:20 AM Today',
      referralStatus: 'Monitoring',
    },
    {
      id: 'H-10043',
      name: 'Hajia Mariama',
      zone: 'Bole CHPS Zone',
      chw: 'Ama Akosua (CHO)',
      tier: 'WATCH',
      reasons: ['Maternal Hb 8.4 g/dL — Moderate Anaemia'],
      overdueDays: 28,
      lastSync: '09:45 AM Today',
      referralStatus: 'Monitoring',
    },
    {
      id: 'H-10044',
      name: "Kofi Mensah's Baby",
      zone: 'Bole CHPS Zone',
      chw: 'Ama Akosua (CHO)',
      tier: 'ROUTINE',
      reasons: ['All clinical parameters normal'],
      overdueDays: 0,
      lastSync: 'Yesterday',
      referralStatus: 'Routine Care',
    },
    {
      id: 'H-10045',
      name: 'Fatima Zohra',
      zone: 'Damongo CHPS Zone',
      chw: 'Ibrahim Fuseini (CHV)',
      tier: 'URGENT',
      reasons: ['Vaginal bleeding reported', 'Overdue 35 days'],
      overdueDays: 35,
      lastSync: '08:15 AM Today',
      referralStatus: 'Sent to District Hospital',
    },
  ];

  const filtered = households.filter((h) => {
    if (activeTier !== 'ALL' && h.tier !== activeTier) return false;
    if (filterZone !== 'ALL' && h.zone !== filterZone) return false;
    return true;
  });

  const urgentCount = households.filter((h) => h.tier === 'URGENT').length;
  const watchCount = households.filter((h) => h.tier === 'WATCH').length;
  const routineCount = households.filter((h) => h.tier === 'ROUTINE').length;

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      {/* Top Header */}
      <header
        style={{
          backgroundColor: '#0A2540',
          color: '#ffffff',
          padding: '20px 32px',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
        }}
      >
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div
              style={{
                width: '36px',
                height: '36px',
                backgroundColor: '#00A896',
                borderRadius: '8px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 'bold',
              }}
            >
              CB
            </div>
            <h1 style={{ margin: 0, fontSize: '22px' }}>CareBridge AI — Regional Supervisor Dashboard</h1>
          </div>
          <p style={{ margin: '4px 0 0 48px', fontSize: '13px', color: '#00A896' }}>
            Savannah & Northern Region CHPS Triage Monitor
          </p>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <span
            style={{
              padding: '6px 12px',
              backgroundColor: 'rgba(0, 168, 150, 0.2)',
              color: '#00A896',
              borderRadius: '20px',
              fontSize: '12px',
              fontWeight: 'bold',
            }}
          >
            ● Live Sync Gateway Online
          </span>
        </div>
      </header>

      {/* Main Content Body */}
      <main style={{ padding: '32px', flex: 1, maxWidth: '1400px', margin: '0 auto', width: '100%', boxSizing: 'border-box' }}>
        {/* Metrics Grid */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '20px', marginBottom: '32px' }}>
          <MetricCard title="Total Synced Households" value={households.length} color="#0A2540" />
          <MetricCard title="Urgent Risk Triage" value={urgentCount} color="#D90429" />
          <MetricCard title="Watch Cases" value={watchCount} color="#F77F00" />
          <MetricCard title="Routine Growth" value={routineCount} color="#2EC4B6" />
        </div>

        {/* Filters and Search Bar */}
        <div
          style={{
            backgroundColor: '#ffffff',
            borderRadius: '16px',
            padding: '20px',
            border: '1px solid #e9ecef',
            marginBottom: '24px',
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
          }}
        >
          <div style={{ display: 'flex', gap: '12px' }}>
            {['ALL', 'URGENT', 'WATCH', 'ROUTINE'].map((t) => (
              <button
                key={t}
                onClick={() => setActiveTier(t)}
                style={{
                  padding: '8px 16px',
                  borderRadius: '20px',
                  border: '1px solid',
                  borderColor: activeTier === t ? '#0A2540' : '#e9ecef',
                  backgroundColor: activeTier === t ? '#0A2540' : '#ffffff',
                  color: activeTier === t ? '#ffffff' : '#1e293b',
                  fontWeight: 'bold',
                  cursor: 'pointer',
                  fontSize: '13px',
                }}
              >
                {t}
              </button>
            ))}
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <span style={{ fontSize: '13px', color: '#64748b', fontWeight: 'bold' }}>CHPS Zone:</span>
            <select
              value={filterZone}
              onChange={(e) => setFilterZone(e.target.value)}
              style={{
                padding: '8px 14px',
                borderRadius: '8px',
                border: '1px solid #e9ecef',
                fontSize: '14px',
                fontWeight: 'bold',
                color: '#0A2540',
              }}
            >
              <option value="ALL">All CHPS Zones</option>
              <option value="Bole CHPS Zone">Bole CHPS Zone</option>
              <option value="Damongo CHPS Zone">Damongo CHPS Zone</option>
            </select>
          </div>
        </div>

        {/* Synced Households Triage Table */}
        <div style={{ backgroundColor: '#ffffff', borderRadius: '16px', border: '1px solid #e9ecef', overflow: 'hidden' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
            <thead>
              <tr style={{ backgroundColor: '#f8f9fa', borderBottom: '1px solid #e9ecef' }}>
                <th style={{ padding: '14px 20px', fontSize: '12px', color: '#64748b' }}>HOUSEHOLD ID</th>
                <th style={{ padding: '14px 20px', fontSize: '12px', color: '#64748b' }}>NAME / HEAD</th>
                <th style={{ padding: '14px 20px', fontSize: '12px', color: '#64748b' }}>CHPS ZONE & CHW</th>
                <th style={{ padding: '14px 20px', fontSize: '12px', color: '#64748b' }}>RISK STATUS</th>
                <th style={{ padding: '14px 20px', fontSize: '12px', color: '#64748b' }}>CLINICAL REASONS</th>
                <th style={{ padding: '14px 20px', fontSize: '12px', color: '#64748b' }}>REFERRAL ACTION</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((item) => (
                <tr key={item.id} style={{ borderBottom: '1px solid #e9ecef' }}>
                  <td style={{ padding: '16px 20px', fontWeight: 'bold', fontSize: '14px', color: '#0A2540' }}>{item.id}</td>
                  <td style={{ padding: '16px 20px', fontSize: '14px', fontWeight: '600' }}>{item.name}</td>
                  <td style={{ padding: '16px 20px', fontSize: '13px', color: '#64748b' }}>
                    <div>{item.zone}</div>
                    <div style={{ fontSize: '11px', color: '#00A896', fontWeight: 'bold' }}>{item.chw}</div>
                  </td>
                  <td style={{ padding: '16px 20px' }}>
                    <span
                      style={{
                        padding: '4px 10px',
                        borderRadius: '6px',
                        fontSize: '12px',
                        fontWeight: 'bold',
                        backgroundColor:
                          item.tier === 'URGENT' ? '#FFEBEE' : item.tier === 'WATCH' ? '#FFF3E0' : '#E0F7F5',
                        color: item.tier === 'URGENT' ? '#D90429' : item.tier === 'WATCH' ? '#F77F00' : '#2EC4B6',
                      }}
                    >
                      {item.tier}
                    </span>
                  </td>
                  <td style={{ padding: '16px 20px', fontSize: '13px', color: '#1e293b' }}>
                    {item.reasons.map((r, i) => (
                      <div key={i}>• {r}</div>
                    ))}
                  </td>
                  <td style={{ padding: '16px 20px', fontSize: '13px', fontWeight: '600', color: '#0A2540' }}>
                    {item.referralStatus}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </main>
    </div>
  );
}

function MetricCard({ title, value, color }: { title: string; value: number; color: string }) {
  return (
    <div
      style={{
        backgroundColor: '#ffffff',
        borderRadius: '16px',
        padding: '20px',
        border: '1px solid #e9ecef',
        boxShadow: '0 4px 12px rgba(0,0,0,0.03)',
      }}
    >
      <div style={{ fontSize: '13px', color: '#64748b', marginBottom: '8px' }}>{title}</div>
      <div style={{ fontSize: '32px', fontWeight: 'bold', color: color }}>{value}</div>
    </div>
  );
}
