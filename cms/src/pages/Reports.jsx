import { useState, useEffect } from 'react';
import api from '../api/axios';

const Reports = () => {
    const [reports, setReports] = useState([]);
    const [dateFilter, setDateFilter] = useState('');

    useEffect(() => {
        api.get('/attendance/all')
            .then(res => {
                const data = res.data.data || res.data;
                if (Array.isArray(data)) setReports(data);
            })
            .catch(err => console.error('Error fetching attendance reports:', err));
    }, []);

    const filtered = dateFilter
        ? reports.filter(r => r.date === dateFilter)
        : reports;

    const fmtTime = (dt) => dt ? new Date(dt).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }) : '—';

    const statusClass = (r) => {
        if (!r.checkInTime) return 'danger';
        if (r.status === 'late') return 'warning';
        return 'success';
    };
    const statusLabel = (r) => {
        if (!r.checkInTime) return 'Absen';
        if (r.status === 'late') return 'Terlambat';
        return 'Tepat Waktu';
    };

    return (
        <>
            <div className="header">
                <div>
                    <h1 className="page-title">Laporan Presensi</h1>
                    <p className="page-subtitle">Rekapitulasi kehadiran karyawan secara lengkap.</p>
                </div>
                <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
                    <input
                        type="date"
                        className="search-input"
                        style={{ width: 'auto' }}
                        value={dateFilter}
                        onChange={e => setDateFilter(e.target.value)}
                    />
                    {dateFilter && (
                        <button className="btn-secondary" onClick={() => setDateFilter('')}>Reset</button>
                    )}
                </div>
            </div>

            <div className="glass card">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                    <div>
                        <h2 className="card-title" style={{ marginBottom: 0 }}>Data Presensi</h2>
                        <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginTop: '2px' }}>{filtered.length} record ditemukan</p>
                    </div>
                </div>
                <div className="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Karyawan</th>
                                <th>Tanggal</th>
                                <th>Check In</th>
                                <th>Check Out</th>
                                <th>Lokasi CI</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            {filtered.length === 0 ? (
                                <tr><td colSpan={6} style={{ textAlign: 'center', padding: '36px', color: 'var(--text-secondary)' }}>Tidak ada data untuk ditampilkan</td></tr>
                            ) : filtered.map(r => (
                                <tr key={r.id}>
                                    <td style={{ fontWeight: 500 }}>{r.user?.name || `User #${r.userId}`}</td>
                                    <td style={{ color: 'var(--text-secondary)' }}>{r.date}</td>
                                    <td>{fmtTime(r.checkInTime)}</td>
                                    <td>{fmtTime(r.checkOutTime)}</td>
                                    <td style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                                        {r.checkInLocationLat ? `${parseFloat(r.checkInLocationLat).toFixed(4)}, ${parseFloat(r.checkInLocationLng).toFixed(4)}` : '—'}
                                    </td>
                                    <td><span className={`badge badge-${statusClass(r)}`}>{statusLabel(r)}</span></td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </>
    );
};

export default Reports;
