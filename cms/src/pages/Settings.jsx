import { useState } from 'react';

const Section = ({ title, children }) => (
    <div style={{ marginBottom: '28px' }}>
        <div style={{ fontSize: '12px', fontWeight: 700, textTransform: 'uppercase', letterSpacing: '1px', color: 'var(--text-secondary)', marginBottom: '16px', paddingBottom: '10px', borderBottom: '1px solid var(--border)' }}>
            {title}
        </div>
        {children}
    </div>
);

const Settings = () => {
    const [config, setConfig] = useState({
        companyName: 'Perusahaan XYZ',
        workStart: '08:00',
        workEnd: '17:00',
        tolerance: '15',
        officeLat: '-6.200000',
        officeLng: '106.816666',
        maxDistance: '50'
    });

    const handleChange = (e) => setConfig({ ...config, [e.target.name]: e.target.value });

    const handleSave = (e) => {
        e.preventDefault();
        alert('Pengaturan berhasil disimpan!');
    };

    return (
        <>
            <div className="header">
                <div>
                    <h1 className="page-title">Pengaturan Sistem</h1>
                    <p className="page-subtitle">Konfigurasi aturan presensi dan informasi perusahaan.</p>
                </div>
            </div>

            <div className="glass card" style={{ maxWidth: '680px' }}>
                <form onSubmit={handleSave}>
                    <Section title="Informasi Umum">
                        <div className="form-group">
                            <label className="form-label">Nama Perusahaan</label>
                            <input type="text" name="companyName" className="form-input" value={config.companyName} onChange={handleChange} />
                        </div>
                    </Section>

                    <Section title="Jam Kerja">
                        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '16px' }}>
                            <div className="form-group" style={{ marginBottom: 0 }}>
                                <label className="form-label">Jam Masuk</label>
                                <input type="time" name="workStart" className="form-input" value={config.workStart} onChange={handleChange} />
                            </div>
                            <div className="form-group" style={{ marginBottom: 0 }}>
                                <label className="form-label">Jam Pulang</label>
                                <input type="time" name="workEnd" className="form-input" value={config.workEnd} onChange={handleChange} />
                            </div>
                            <div className="form-group" style={{ marginBottom: 0 }}>
                                <label className="form-label">Toleransi (menit)</label>
                                <input type="number" name="tolerance" className="form-input" value={config.tolerance} onChange={handleChange} min="0" />
                            </div>
                        </div>
                    </Section>

                    <Section title="Validasi Lokasi Kantor">
                        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '16px' }}>
                            <div className="form-group" style={{ marginBottom: 0 }}>
                                <label className="form-label">Latitude Kantor</label>
                                <input type="text" name="officeLat" className="form-input" value={config.officeLat} onChange={handleChange} />
                            </div>
                            <div className="form-group" style={{ marginBottom: 0 }}>
                                <label className="form-label">Longitude Kantor</label>
                                <input type="text" name="officeLng" className="form-input" value={config.officeLng} onChange={handleChange} />
                            </div>
                        </div>
                        <div className="form-group">
                            <label className="form-label">Jarak Maksimum (meter)</label>
                            <input type="number" name="maxDistance" className="form-input" value={config.maxDistance} onChange={handleChange} style={{ maxWidth: '200px' }} />
                        </div>
                    </Section>

                    <button type="submit" className="btn-primary" style={{ width: 'auto', padding: '12px 32px' }}>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v11a2 2 0 01-2 2zM17 21v-8H7v8M7 3v5h8"/></svg>
                        Simpan Perubahan
                    </button>
                </form>
            </div>
        </>
    );
};

export default Settings;
