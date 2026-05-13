import { useState, useEffect } from 'react';
import api from '../api/axios';

const ManageUsers = () => {
    const [users, setUsers] = useState([]);
    const [search, setSearch] = useState('');

    useEffect(() => {
        api.get('/users')
            .then(res => {
                const data = res.data.data || res.data;
                if (Array.isArray(data)) setUsers(data);
            })
            .catch(err => console.error('Error fetching users:', err));
    }, []);

    const filtered = users.filter(u =>
        (u.name || u.username || '').toLowerCase().includes(search.toLowerCase()) ||
        (u.email || '').toLowerCase().includes(search.toLowerCase())
    );

    const initials = (name) => (name || '?').charAt(0).toUpperCase();

    return (
        <>
            <div className="header">
                <div>
                    <h1 className="page-title">Manajemen User</h1>
                    <p className="page-subtitle">Kelola data karyawan dan hak akses sistem.</p>
                </div>
                <button className="btn-primary" style={{ width: 'auto', padding: '10px 20px' }}>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M12 5v14M5 12h14"/></svg>
                    Tambah User
                </button>
            </div>

            <div className="glass card">
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                    <div>
                        <h2 className="card-title" style={{ marginBottom: 0 }}>Daftar Karyawan</h2>
                        <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginTop: '2px' }}>{users.length} karyawan terdaftar</p>
                    </div>
                    <input
                        type="search"
                        className="search-input"
                        placeholder="🔍  Cari nama atau email..."
                        value={search}
                        onChange={e => setSearch(e.target.value)}
                    />
                </div>

                <div className="table-wrapper">
                    <table>
                        <thead>
                            <tr>
                                <th>Karyawan</th>
                                <th>Email</th>
                                <th>Jabatan</th>
                                <th>Role</th>
                                <th style={{ textAlign: 'right' }}>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            {filtered.length === 0 ? (
                                <tr><td colSpan={5} style={{ textAlign: 'center', padding: '36px', color: 'var(--text-secondary)' }}>Tidak ada data karyawan</td></tr>
                            ) : filtered.map(user => (
                                <tr key={user.id}>
                                    <td>
                                        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                                            <div style={{ width: 32, height: 32, borderRadius: '50%', background: 'var(--primary-light)', border: '1px solid var(--border-active)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '13px', fontWeight: 700, color: 'var(--primary)', flexShrink: 0 }}>
                                                {initials(user.name || user.username)}
                                            </div>
                                            <span style={{ fontWeight: 500 }}>{user.name || user.username}</span>
                                        </div>
                                    </td>
                                    <td style={{ color: 'var(--text-secondary)' }}>{user.email}</td>
                                    <td>{user.position || user.department || '—'}</td>
                                    <td>
                                        <span className={`badge badge-${user.role === 'admin' ? 'primary' : 'success'}`}>
                                            {user.role || 'employee'}
                                        </span>
                                    </td>
                                    <td style={{ textAlign: 'right' }}>
                                        <button className="action-btn edit">Edit</button>
                                        <button className="action-btn delete">Hapus</button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </>
    );
};

export default ManageUsers;
