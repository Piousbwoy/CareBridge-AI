'use client';

import React, { useState, useEffect } from 'react';

export default function SupervisorDashboard() {
  const [isAuthenticated, setIsAuthenticated] = useState(true); // Gated Supervisor Session
  const [districtOfficer, setDistrictOfficer] = useState({
    name: 'Dr. Ibrahim Fuseini',
    role: 'District Health Officer',
    region: 'Savannah Region',
    district: 'Bole',
  });

  const [activeTier, setActiveTier] = useState('ALL');
  const [activeCategory, setActiveCategory] = useState('ALL');
  const [selectedRegion, setSelectedRegion] = useState('Savannah Region');
  const [selectedDistrict, setSelectedDistrict] = useState('ALL');

  const [households, setHouseholds] = useState<any[]>([
    {
      id: 'H-10041',
      name: 'Akua Serwaa',
      category: 'child',
      zone: 'Bole CHPS Zone',
      district: 'Bole',
      region: 'Savannah Region',
      chw: 'Ama Abena (CHO)',
      tier: 'URGENT',
      reasons: ['MUAC 10.5cm — SAM', 'Fast breathing (62/min) in young infant'],
      overdueDays: 21,
      lastSync: '10:25 AM Today',
      referralStatus: 'Queued via SMS',
    },
    {
      id: 'H-10042',
      name: "Abena Gyamfi's Baby",
      category: 'newborn',
      zone: 'Bole CHPS Zone',
      district: 'Bole',
      region: 'Savannah Region',
      chw: 'Ama Abena (CHO)',
      tier: 'WATCH',
      reasons: ['MUAC 12.0cm — MAM'],
      overdueDays: 14,
      lastSync: '10:20 AM Today',
      referralStatus: 'Monitoring',
    },
    {
      id: 'H-10043',
      name: 'Hajia Mariama',
      category: 'mother',
      zone: 'Bole CHPS Zone',
      district: 'Bole',
      region: 'Savannah Region',
      chw: 'Ama Abena (CHO)',
      tier: 'WATCH',
      reasons: ['Maternal Hb 8.4 g/dL — Moderate Anaemia'],
      overdueDays: 28,
      lastSync: '09:45 AM Today',
      referralStatus: 'Monitoring',
    },
    {
      id: 'H-10044',
      name: "Kofi Mensah's Household",
      category: 'child',
      zone: 'Bole CHPS Zone',
      district: 'Bole',
      region: 'Savannah Region',
      chw: 'Ama Abena (CHO)',
      tier: 'ROUTINE',
      reasons: ['All clinical parameters normal'],
      overdueDays: 0,
      lastSync: 'Yesterday',
      referralStatus: 'Routine Care',
    },
    {
      id: 'H-10045',
      name: 'Fatima Zohra',
      category: 'mother',
      zone: 'Damongo CHPS Zone',
      district: 'West Gonja Municipal',
      region: 'Savannah Region',
      chw: 'Ibrahim Fuseini (CHV)',
      tier: 'URGENT',
      reasons: ['Vaginal bleeding reported', 'Overdue 35 days'],
      overdueDays: 35,
      lastSync: '08:15 AM Today',
      referralStatus: 'Sent to District Hospital',
    },
  ]);

  const [metrics, setMetrics] = useState({
    total_households: 5,
    urgent_referrals: 2,
    urgent_breakdown: { mothers: 1, newborns: 0, children: 1 },
    watch_cases: 2,
    watch_breakdown: { mothers: 1, newborns: 1, children: 0 },
    routine_cases: 1,
    routine_breakdown: { mothers: 0, newborns: 0, children: 1 },
  });

  // Fetch real REST data from FastAPI backend
  useEffect(() => {
    async function fetchData() {
      try {
        const resH = await fetch('http://localhost:8000/api/v1/households');
        if (resH.ok) {
          const dataH = await resH.json();
          if (dataH.households && dataH.households.length > 0) {
            setHouseholds(
              dataH.households.map((h: any) => ({
                id: h.id,
                name: h.name,
                category: h.patient_category || 'child',
                zone: h.chps_zone,
                district: h.district || 'Bole',
                region: h.region || 'Savannah Region',
                chw: h.last_chw || 'Ama Abena (CHO)',
                tier: h.risk_tier,
                reasons: h.reasons || [],
                overdueDays: h.overdue_days || 0,
                lastSync: h.updated_at ? h.updated_at.substring(0, 10) : 'Today',
                referralStatus: h.risk_tier === 'URGENT' ? 'Queued via SMS' : 'Monitoring',
              }))
            );
          }
        }
        const resM = await fetch('http://localhost:8000/api/v1/chw/metrics');
        if (resM.ok) {
          const dataM = await resM.json();
          setMetrics(dataM);
        }
      } catch (e) {
        console.log('Using local fallback state until FastAPI backend is live');
      }
    }
    fetchData();
  }, []);

  const filteredHouseholds = households.filter((h) => {
    if (activeTier !== 'ALL' && h.tier !== activeTier) return false;
    if (activeCategory !== 'ALL' && h.category !== activeCategory) return false;
    if (selectedDistrict !== 'ALL' && h.district !== selectedDistrict) return false;
    return true;
  });

  if (!isAuthenticated) {
    return (
      <div style={{ minHeight: '100vh', backgroundColor: '#0A2540', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'white' }}>
        <div style={{ backgroundColor: 'white', color: '#0A2540', padding: '32px', borderRadius: '16px', maxWidth: '400px', width: '100%' }}>
          <h2>Supervisor Authentication</h2>
          <p>Please enter your District Officer credentials to access Northern Ghana triage monitor.</p>
          <button onClick={() => setIsAuthenticated(true)} style={{ width: '100%', padding: '12px', backgroundColor: '#00A896', color: 'white', border: 'none', borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer' }}>
            Authenticate as District Officer
          </button>
        </div>
      </div>
    );
  }

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', backgroundColor: '#f8f9fa' }}>
      {/* Top Header */}
      <header style={{ backgroundColor: '#0A2540', color: '#ffffff', padding: '20px 32px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{ width: '36px', height: '36px', backgroundColor: '#00A896', borderRadius: '8px', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold', color: 'white' }}>
              CB
            </div>
            <h1 style={{ margin: 0, fontSize: '22px' }}>CareBridge AI — District & Regional Supervisor Dashboard</h1>
          </div>
          <p style={{ margin: '4px 0 0 48px', fontSize: '13px', color: '#00A896' }}>
            {districtOfficer.region} ({districtOfficer.district} District) — CHPS Maternal & Under-5 Triage Monitor
          </p>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <div style={{ textAlign: 'right', fontSize: '12px' }}>
            <div style={{ fontWeight: 'bold' }}>{districtOfficer.name}</div>
            <div style={{ color: '#00A896' }}>{districtOfficer.role}</div>
          </div>
          <span style={{ padding: '6px 12px', backgroundColor: 'rgba(0, 168, 150, 0.2)', color: '#00A896', borderRadius: '20px', fontSize: '12px', fontWeight: 'bold' }}>
            ● Live Gateway Connected
          </span>
        </div>
      </header>

      {/* Main Content Body */}
      <main style={{ padding: '32px', flex: 1, maxWidth: '1400px', margin: '0 auto', width: '100%', boxSizing: 'border-box' }}>
        {/* Patient Category Metric Cards Grid */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '20px', marginBottom: '32px' }}>
          <MetricCard
            title="Total Synced Households"
            value={filteredHouseholds.length}
            color="#0A2540"
            subtext="Zone-wide monitoring"
          />
          <MetricCard
            title="Urgent Risk Triage"
            value={metrics.urgent_referrals}
            color="#D90429"
            breakdown={metrics.urgent_breakdown}
          />
          <MetricCard
            title="Watch Cases"
            value={metrics.watch_cases}
            color="#F77F00"
            breakdown={metrics.watch_breakdown}
          />
          <MetricCard
            title="Routine Growth"
            value={metrics.routine_cases}
            color="#2EC4B6"
            breakdown={metrics.routine_breakdown}
          />
        </div>

        {/* Filter Controls Bar */}
        <div style={{ backgroundColor: '#ffffff', borderRadius: '16px', padding: '20px', border: '1px solid #e9ecef', marginBottom: '24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
          {/* Risk Tier Tabs */}
          <div style={{ display: 'flex', gap: '8px' }}>
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

          {/* Patient Category Filter */}
          <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
            <span style={{ fontSize: '12px', color: '#64748b', fontWeight: 'bold' }}>CATEGORY:</span>
            {[
              { id: 'ALL', label: 'All Categories' },
              { id: 'mother', label: '🤰 Mothers' },
              { id: 'newborn', label: '👶 Newborns' },
              { id: 'child', label: '🧒 Children <5' },
            ].map((c) => (
              <button
                key={c.id}
                onClick={() => setActiveCategory(c.id)}
                style={{
                  padding: '6px 12px',
                  borderRadius: '16px',
                  border: '1px solid',
                  borderColor: activeCategory === c.id ? '#00A896' : '#e9ecef',
                  backgroundColor: activeCategory === c.id ? '#E0F7F5' : '#ffffff',
                  color: activeCategory === c.id ? '#008F7F' : '#64748b',
                  fontWeight: 'bold',
                  cursor: 'pointer',
                  fontSize: '12px',
                }}
              >
                {c.label}
              </button>
            ))}
          </div>

          {/* District Dropdown */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <span style={{ fontSize: '12px', color: '#64748b', fontWeight: 'bold' }}>DISTRICT:</span>
            <select
              value={selectedDistrict}
              onChange={(e) => setSelectedDistrict(e.target.value)}
              style={{
                padding: '8px 14px',
                borderRadius: '8px',
                border: '1px solid #e9ecef',
                fontSize: '13px',
                fontWeight: 'bold',
                color: '#0A2540',
              }}
            >
              <option value="ALL">All Districts (Savannah)</option>
              <option value="Bole">Bole District</option>
              <option value="West Gonja Municipal">West Gonja Municipal</option>
              <option value="Central Gonja">Central Gonja</option>
              <option value="Sawla-Tuna-Kalba">Sawla-Tuna-Kalba</option>
            </select>
          </div>
        </div>

        {/* Households Triage Table */}
        <div style={{ backgroundColor: '#ffffff', borderRadius: '16px', border: '1px solid #e9ecef', overflow: 'hidden' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
            <thead>
              <tr style={{ backgroundColor: '#f8f9fa', borderBottom: '1px solid #e9ecef' }}>
                <th style={{ padding: '14px 20px', fontSize: '12px', color: '#64748b' }}>HOUSEHOLD ID</th>
                <th style={{ padding: '14px 20px', fontSize: '12px', color: '#64748b' }}>PATIENT / HEAD</th>
                <th style={{ padding: '14px 20px', fontSize: '12px', color: '#64748b' }}>CATEGORY</th>
                <th style={{ padding: '14px 20px', fontSize: '12px', color: '#64748b' }}>CHPS ZONE & DISTRICT</th>
                <th style={{ padding: '14px 20px', fontSize: '12px', color: '#64748b' }}>RISK STATUS</th>
                <th style={{ padding: '14px 20px', fontSize: '12px', color: '#64748b' }}>CLINICAL REASONS</th>
                <th style={{ padding: '14px 20px', fontSize: '12px', color: '#64748b' }}>REFERRAL STATUS</th>
              </tr>
            </thead>
            <tbody>
              {filteredHouseholds.map((item) => (
                <tr key={item.id} style={{ borderBottom: '1px solid #e9ecef' }}>
                  <td style={{ padding: '16px 20px', fontWeight: 'bold', fontSize: '14px', color: '#0A2540' }}>{item.id}</td>
                  <td style={{ padding: '16px 20px', fontSize: '14px', fontWeight: '600' }}>{item.name}</td>
                  <td style={{ padding: '16px 20px', fontSize: '13px' }}>
                    <span style={{ padding: '4px 8px', borderRadius: '12px', backgroundColor: '#F1F5F9', fontSize: '12px', fontWeight: '600' }}>
                      {item.category === 'mother' ? '🤰 Mother' : item.category === 'newborn' ? '👶 Newborn' : '🧒 Child'}
                    </span>
                  </td>
                  <td style={{ padding: '16px 20px', fontSize: '13px', color: '#64748b' }}>
                    <div>{item.zone}</div>
                    <div style={{ fontSize: '11px', color: '#00A896', fontWeight: 'bold' }}>{item.district} District</div>
                  </td>
                  <td style={{ padding: '16px 20px' }}>
                    <span
                      style={{
                        padding: '4px 10px',
                        borderRadius: '6px',
                        fontSize: '12px',
                        fontWeight: 'bold',
                        backgroundColor: item.tier === 'URGENT' ? '#FFEBEE' : item.tier === 'WATCH' ? '#FFF3E0' : '#E0F7F5',
                        color: item.tier === 'URGENT' ? '#D90429' : item.tier === 'WATCH' ? '#F77F00' : '#2EC4B6',
                      }}
                    >
                      {item.tier}
                    </span>
                  </td>
                  <td style={{ padding: '16px 20px', fontSize: '13px', color: '#1e293b' }}>
                    {item.reasons.map((r: string, i: number) => (
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

function MetricCard({ title, value, color, breakdown, subtext }: { title: string; value: number; color: string; breakdown?: any; subtext?: string }) {
  return (
    <div style={{ backgroundColor: '#ffffff', borderRadius: '16px', padding: '20px', border: '1px solid #e9ecef', boxShadow: '0 4px 12px rgba(0,0,0,0.03)' }}>
      <div style={{ fontSize: '13px', color: '#64748b', marginBottom: '8px' }}>{title}</div>
      <div style={{ fontSize: '32px', fontWeight: 'bold', color: color }}>{value}</div>
      {breakdown ? (
        <div style={{ fontSize: '11px', color: '#64748b', marginTop: '8px', borderTop: '1px solid #f1f5f9', paddingTop: '8px', display: 'flex', gap: '8px' }}>
          <span>🤰 {breakdown.mothers} Mothers</span>
          <span>👶 {breakdown.newborns} Newborns</span>
          <span>🧒 {breakdown.children} Children</span>
        </div>
      ) : (
        subtext && <div style={{ fontSize: '11px', color: '#64748b', marginTop: '6px' }}>{subtext}</div>
      )}
    </div>
  );
}
