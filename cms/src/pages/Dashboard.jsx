import { useEffect, useState } from 'react';
import api from '../api/axios';

const StatCard = ({ label, value, icon, color, badge, badgeClass }) => (
    <div className="stat-card glass">
        <div className="stat-header">
            <span className="stat-label">{label}</span>
            <div className="stat-icon" style={{ background: `${color}18`, border: `1px solid ${color}30` }}>
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d={icon} />
                </svg>
            </div>
        </div>
        <div className="stat-value" style={{ color }}>{value ?? '—'}</div>
        {badge && <span className={`badge badge-${badgeClass}`}>{badge}</span>}
    </div>
);

const Dashboard = () => {
    const [stats, setStats] = useState(null);
    const [recent, setRecent] = useState([]);

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const [usersRes, attRes] = await Promise.all([
                    api.get('/users'),
                    api.get('/attendance/all')
                ]);
                const users = usersRes.data.data || usersRes.data;
                const attendances = attRes.data.data || attRes.data;
                const today = new Date().toISOString().split('T')[0];
                const todayAtt = Array.isArray(attendances) ? attendances.filter(a => a.date?.startsWith(today)) : [];
                const late = todayAtt.filter(a => a.status === 'late').length;
                const present = todayAtt.filter(a => a.checkInTime).length;
                const totalUsers = Array.isArray(users) ? users.length : 0;

                setStats({ totalUsers, present, late, absent: totalUsers - present });
                setRecent(Array.isArray(attendances) ? attendances.slice(0, 6) : []);
            } catch (err) {
                console.error('Error fetching stats:', err);
            }
        };
        fetchStats();
    }, []);

    return (
        <>
            <div className="header">
                <div>
                    <h1 className="page-title">Dashboard</h1>
                    <p className="page-subtitle">Selamat datang! Berikut ringkasan presensi hari ini.</p>
                </div>
                <div style={{ fontSize: '13px', color: 'var(--text-secondary)', padding: '8px 14px', background: 'var(--surface-hover)', borderRadius: '8px', border: '1px solid var(--border)' }}>
                    {new Date().toLocaleDateString('id-ID', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
                </div>
            </div>

            <div className="stat-grid">
                <StatCard label="Total Karyawan" value={stats?.totalUsers} color="#6366f1"
                    icon="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2M9 11a4 4 0 100-8 4 4 0 000 8z"
                    badge="Terdaftar" badgeClass="primary" />
                <StatCard label="Hadir Hari Ini" value={stats?.present} color="#10b981"
                    icon="M22 11.08V12a10 10 0 11-5.93-9.14M22 4L12 14.01l-3-3"
                    badge="On-time" badgeClass="success" />
                <StatCard label="Terlambat / Izin" value={stats?.late} color="#f59e0b"
                    icon="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"
                    badge="Perlu Perhatian" badgeClass="warning" />
                <StatCard label="Belum Presensi" value={stats?.absent} color="#ef4444"
                    icon="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
                    badge="Absen" badgeClass="danger" />
            </div>

            <div className="glass card">
                <h2 className="card-title">Aktivitas Presensi Terbaru</h2>
                <p className="card-subtitle">Data check-in karyawan hari ini secara real-time</p>
                <div className="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Karyawan</th>
                                <th>Tanggal</th>
                                <th>Check In</th>
                                <th>Check Out</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            {recent.length === 0 ? (
                                <tr><td colSpan={5} style={{ textAlign: 'center', padding: '32px', color: 'var(--text-secondary)' }}>Tidak ada data presensi</td></tr>
                            ) : recent.map(r => (
                                <tr key={r.id}>
                                    <td style={{ fontWeight: 500 }}>{r.user?.name || `User #${r.userId}`}</td>
                                    <td style={{ color: 'var(--text-secondary)' }}>{r.date}</td>
                                    <td>{r.checkInTime ? new Date(r.checkInTime).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }) : '—'}</td>
                                    <td>{r.checkOutTime ? new Date(r.checkOutTime).toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }) : '—'}</td>
                                    <td><span className={`badge badge-${r.status === 'late' ? 'warning' : r.checkInTime ? 'success' : 'danger'}`}>{r.status === 'late' ? 'Terlambat' : r.checkInTime ? 'Hadir' : 'Absen'}</span></td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </>
    );
};

export default Dashboard;
