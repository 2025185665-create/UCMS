
/* ---------- INITIAL DATA ---------- */
const ADMIN_ID = '999';
const ADMIN_PASSWORD = 'admin';

const initialClubs = [
    { id: '001', name: 'Campus FC', description: 'A dynamic club for students passionate about football. Members participate in weekly training, friendly matches, inter-university tournaments, and skill-building sessions.', category: 'Sports' },
    { id: '002', name: "Readers' Circle", description: "A welcoming community for readers who enjoy exploring books of all genres. Activities include book discussions, reading challenges, literary sharing sessions, study hangouts, and author appreciation events.", category: 'Academic' },
    { id: '003', name: 'Helping Hands Society', description: 'Focused on giving back to society, this club organizes charity drives, community outreach programs, environmental initiatives, and volunteer projects.', category: 'Social' },
    { id: '004', name: 'Outdoor Explorers', description: 'A club for students who love nature, adventure, and physical activities. Members participate in hiking, camping, cycling, jungle trekking, eco-walks, and nature photography outings.', category: 'Recreation' },
    { id: '005', name: 'BIZNESS', description: 'A club that nurtures future entrepreneurs and business leaders. Activities include business workshops, pitch competitions, financial literacy sessions, networking events, and small-scale student business projects.', category: 'Academic' },
];

const initialMemberships = [
    { studentId: '1234567', clubId: '001', studentName: 'Student A', joinDate: '02/01/2025' },
    { studentId: '1234567', clubId: '002', studentName: 'Student A', joinDate: '02/02/2025' },
    { studentId: 'M101', clubId: '001', studentName: 'ALI BIN ABU', joinDate: '02/01/2025' },
    { studentId: 'M102', clubId: '001', studentName: 'ABU BIN ALI', joinDate: '02/02/2025' },
    { studentId: 'M103', clubId: '004', studentName: 'ALIA BINTI ALI', joinDate: '15/03/2025' },
];

const initialEvents = [
    { id: 'E001', name: 'Midnight Mystery Readathon', clubName: "Readers' Circle", location: 'University Library (Level 3)', date: '12/01/2025', time: '8:00 PM', description: 'A late-night reading session filled with mystery and thriller stories.' },
    { id: 'E002', name: 'Campus Cup Friendly Match', clubName: 'Campus FC', location: 'University Sports Complex', date: '20/01/2025', time: '5:00 PM', description: 'The match between Team Alpha and Team Phoenix.' },
    { id: 'E003', name: 'Hope for All Charity Drive', clubName: 'Helping Hands Society', location: 'Student Centre Hall', date: '25/01/2025', time: '9:00 AM', description: 'Collect, sort, and pack essential items for families in need.' },
];

/* ---------- STORAGE HELPERS ---------- */
function safeGet(key) {
    const raw = localStorage.getItem(key);
    return raw ? JSON.parse(raw) : null;
}
function safeSet(key, data) {
    localStorage.setItem(key, JSON.stringify(data));
}

/* initialize baseline data */
function bootstrapData() {
    if (!safeGet('ucmsUsers')) {
        const initialUsers = [
            { id: ADMIN_ID, name: 'Admin User', email: 'admin@u.edu', password: ADMIN_PASSWORD, role: 'admin' },
            { id: '1234567', name: 'Student A', email: 's@u.edu', password: 'password', role: 'student' },
        ];
        safeSet('ucmsUsers', initialUsers);
    }
    if (!safeGet('ucmsClubs')) safeSet('ucmsClubs', initialClubs);
    if (!safeGet('ucmsMemberships')) safeSet('ucmsMemberships', initialMemberships);
    if (!safeGet('ucmsEvents')) safeSet('ucmsEvents', initialEvents);
}

/* getters & setters */
function getUsers() { return safeGet('ucmsUsers') || []; }
function getClubs() { return safeGet('ucmsClubs') || []; }
function getMemberships() { return safeGet('ucmsMemberships') || []; }
function getEvents() { return safeGet('ucmsEvents') || []; }
function saveUsers(u){ safeSet('ucmsUsers', u); }
function saveClubs(c){ safeSet('ucmsClubs', c); }
function saveMemberships(m){ safeSet('ucmsMemberships', m); }
function saveEvents(e){ safeSet('ucmsEvents', e); }

/* ---------- AUTH STORAGE ---------- */
function login(id, password) {
    const users = getUsers();
    const user = users.find(u => u.id === id && u.password === password);
    if (user) {
        sessionStorage.setItem('ucmsCurrentUser', JSON.stringify(user));
        return { ok: true, user };
    } else {
        return { ok: false, message: 'Invalid ID or password.' };
    }
}
function logout() {
    sessionStorage.removeItem('ucmsCurrentUser');
}
function currentUser() {
    return JSON.parse(sessionStorage.getItem('ucmsCurrentUser') || 'null');
}

/* ---------- NOTIFICATIONS ---------- */
function notify(message, type='success') {
    const area = document.getElementById('notification-area');
    if (!area) {
        // if page not containing area, fallback to alert
        console[type === 'success' ? 'log' : 'warn'](message);
        return;
    }
    const colorClass = type === 'success' ? 'bg-green-600' : 'bg-red-600';
    const toast = document.createElement('div');
    toast.className = `notification ${colorClass} text-white`;
    toast.textContent = message;
    area.appendChild(toast);
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.addEventListener('transitionend', ()=> toast.remove());
    }, 3000);
}

/* ---------- UTILS ---------- */
function getLogoHtml(sizeClass='w-10 h-10') {
    // small inline logo
    return `
        <div style="display:flex;align-items:center;gap:.5rem;">
            <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 100 100">
                <polygon points="50,10 80,45 80,75 50,90 20,75 20,45" fill="#4E869B" stroke="#fff" stroke-width="5"/>
                <text x="50" y="60" font-family="Arial, sans-serif" font-size="15" fill="#fff" text-anchor="middle" font-weight="bold">U</text>
            </svg>
            <div style="font-size:12px;font-weight:700;color:var(--color-logo);line-height:1;">
                UCMS<br/><span style="font-size:10px;">SOCIETY</span>
            </div>
        </div>
    `;
}

/* ---------- NAV / REDIRECT HELPERS ---------- */
function requireLogin(redirectTo='../login.html') {
    if (!currentUser()) {
        window.location.href = redirectTo;
        return false;
    }
    return true;
}
function requireRole(role, redirectTo='../dashboard.html') {
    const u = currentUser();
    if (!u || u.role !== role) {
        window.location.href = redirectTo;
        return false;
    }
    return true;
}

/* ---------- PAGE RENDER FUNCTIONS ---------- */
/* Admin: clubs page */
function renderAdminClubsTable() {
    const tbody = document.getElementById('admin-clubs-tbody');
    if (!tbody) return;
    const clubs = getClubs();
    tbody.innerHTML = clubs.map(c => `
        <tr>
            <td>${c.id}</td>
            <td>${c.name}</td>
            <td>${c.description.substring(0,100)}${c.description.length>100?'...':''}</td>
            <td>${c.category}</td>
            <td class="whitespace-nowrap space-x-2">
                <button class="btn-action" onclick="adminEditClub('${c.id}')">EDIT</button>
                <button class="btn-delete" onclick="adminDeleteClub('${c.id}')">DELETE</button>
            </td>
        </tr>
    `).join('') || '<tr><td colspan="5">No clubs</td></tr>';
}
function adminEditClub(id) {
    const clubs = getClubs();
    const club = clubs.find(c=>c.id===id);
    if (!club) { notify('Club not found','error'); return; }
    const newName = prompt('Club name', club.name);
    if (!newName) return;
    club.name = newName;
    saveClubs(clubs);
    renderAdminClubsTable();
    notify('Club updated','success');
}
function adminDeleteClub(id) {
    if (!confirm('Delete this club?')) return;
    let clubs = getClubs();
    clubs = clubs.filter(c=>c.id!==id);
    saveClubs(clubs);
    renderAdminClubsTable();
    notify('Club deleted','success');
}

/* Admin: memberships page */
function renderAdminMembershipsTable() {
    const tbody = document.getElementById('admin-memberships-tbody');
    if (!tbody) return;
    const mems = getMemberships();
    tbody.innerHTML = mems.map(m => `
        <tr>
            <td>${m.studentId}</td>
            <td>${m.clubId}</td>
            <td>${m.studentName}</td>
            <td>${m.joinDate}</td>
            <td>
                <button class="btn-action" onclick="notify('Edit member not implemented','success')">EDIT</button>
                <button class="btn-delete" onclick="notify('Delete member not implemented','success')">DELETE</button>
            </td>
        </tr>
    `).join('') || '<tr><td colspan="5">No memberships</td></tr>';
}

/* Admin: events */
function renderAdminEventsTable() {
    const tbody = document.getElementById('admin-events-tbody');
    if (!tbody) return;
    const events = getEvents();
    tbody.innerHTML = events.map(ev => `
        <tr>
            <td>${ev.name}</td>
            <td>${ev.clubName}</td>
            <td>${ev.location}</td>
            <td>${ev.date}</td>
            <td>${ev.time}</td>
            <td>${ev.description.substring(0,40)}${ev.description.length>40?'...':''}</td>
            <td>
                <button class="btn-action" onclick="notify('Edit event not implemented','success')">EDIT</button>
                <button class="btn-delete" onclick="notify('Delete event not implemented','success')">DELETE</button>
            </td>
        </tr>
    `).join('') || '<tr><td colspan="7">No events</td></tr>';
}

/* Admin: dashboard counts */
function renderAdminOverview() {
    const clubsCnt = document.getElementById('admin-count-clubs');
    const memsCnt = document.getElementById('admin-count-memberships');
    const eventsCnt = document.getElementById('admin-count-events');
    if (clubsCnt) clubsCnt.textContent = getClubs().length;
    if (memsCnt) memsCnt.textContent = getMemberships().length;
    if (eventsCnt) eventsCnt.textContent = getEvents().length;
}

/* Student: show clubs */
function renderStudentClubs() {
    const container = document.getElementById('student-clubs-container');
    if (!container) return;
    const user = currentUser();
    const clubs = getClubs();
    const mems = getMemberships().filter(m => user ? m.studentId === user.id : false);
    const html = clubs.map(club => {
        const isMember = mems.some(m => m.clubId === club.id);
        const btnHtml = isMember
            ? `<div class="bg-gray-400 cursor-not-allowed text-white p-2 rounded w-full text-center">ALREADY JOINED</div>`
            : `<a href="membership.html?preselect=${club.id}" class="btn-action w-full inline-block text-center">JOIN CLUB</a>`;
        return `
            <div class="p-6 bg-white rounded-lg shadow-md border border-gray-100 transition duration-300 hover:shadow-lg">
                <h3 class="text-xl font-bold text-gray-800">${club.name}</h3>
                <p class="text-sm text-gray-500 mt-1 mb-3 font-semibold">${club.category} (${club.id})</p>
                <p class="text-sm text-gray-700 mb-4">${club.description}</p>
                ${btnHtml}
            </div>
        `;
    }).join('');
    container.innerHTML = `<div class="grid grid-cols-1 md:grid-cols-2 gap-6">${html}</div>`;
}

/* Student: membership form */
function renderStudentMembershipForm() {
    const select = document.getElementById('membership-club-select');
    if (!select) return;
    const url = new URL(window.location.href);
    const pre = url.searchParams.get('preselect') || '';
    const clubs = getClubs();
    select.innerHTML = `<option value="">-- Select a Club --</option>` + clubs.map(c => `<option value="${c.id}" ${c.id===pre?'selected':''}>${c.name} (${c.id})</option>`).join('');
    // populate user fields
    const user = currentUser();
    if (user) {
        const nameField = document.getElementById('membership-name');
        const idField = document.getElementById('membership-student_id');
        if (nameField) nameField.value = user.name;
        if (idField) idField.value = user.id;
    }
}
function handleMembershipRegistrationSubmit(e) {
    e.preventDefault();
    const clubId = document.getElementById('membership-club-select').value;
    if (!clubId) { notify('Please select a club','error'); return; }
    const user = currentUser();
    if (!user) { notify('Not logged in','error'); window.location.href='../login.html'; return; }
    let mems = getMemberships();
    if (mems.some(m => m.studentId === user.id && m.clubId === clubId)) { notify('Already a member','error'); return; }
    mems.push({ studentId: user.id, clubId: clubId, studentName: user.name, joinDate: new Date().toLocaleDateString('en-GB') });
    saveMemberships(mems);
    notify('Successfully registered for club', 'success');
    setTimeout(()=> window.location.href='output.html',700);
}

/* Student: events */
function renderStudentEvents() {
    const select = document.getElementById('event-select');
    if (!select) return;
    const events = getEvents();
    select.innerHTML = `<option value="">-- Select an Event --</option>` + events.map(ev => `<option value="${ev.id}">[${ev.clubName}] ${ev.name} on ${ev.date}</option>`).join('');
}
function handleEventRegistrationSubmit(e) {
    e.preventDefault();
    const eventId = document.getElementById('event-select').value;
    if (!eventId) { notify('Select an event','error'); return; }
    const ev = getEvents().find(x => x.id === eventId);
    notify(`You have registered for the event: ${ev ? ev.name : eventId}`, 'success');
    setTimeout(()=> window.location.href='buzz.html',700);
}

/* Student: output */
function renderStudentOutput() {
    const tbody = document.getElementById('student-memberships-tbody');
    if (!tbody) return;
    const user = currentUser();
    if (!user) { tbody.innerHTML = '<tr><td colspan="4">Not logged in</td></tr>'; return; }
    const mems = getMemberships().filter(m => m.studentId === user.id);
    const clubs = getClubs();
    tbody.innerHTML = mems.length ? mems.map(m => {
        const club = clubs.find(c=>c.id===m.clubId);
        return `<tr><td>${m.clubId}</td><td>${club?club.name:'Unknown'}</td><td>${m.joinDate}</td><td><button class="btn-delete" onclick="notify('Quit club not implemented','success')">QUIT CLUB</button></td></tr>`;
    }).join('') : `<tr><td colspan="4" class="text-center">No club memberships found.</td></tr>`;
}

/* Campus buzz */
function renderCampusBuzz() {
    const container = document.getElementById('campus-buzz-container');
    if (!container) return;
    const events = getEvents();
    const eventHtml = events.map(e => `
        <div class="p-4 bg-white rounded-lg shadow-md border-l-4 border-blue-500 transition duration-300 hover:shadow-xl mb-4">
            <p class="text-xs font-semibold text-blue-600 uppercase">${e.clubName} Event</p>
            <h3 class="text-lg font-bold text-gray-800 mt-1">${e.name}</h3>
            <p class="text-sm text-gray-700 mt-1"><span class="font-bold">🗓️ ${e.date}</span> at ${e.time} | <span class="font-bold">📍 ${e.location}</span></p>
            <p class="text-sm text-gray-600 mt-3">${e.description}</p>
            <button onclick="window.location.href='event.html'" class="btn-action mt-3">Register Now →</button>
        </div>
    `).join('');
    const announcement = `
        <div class="p-6 bg-yellow-100 rounded-xl shadow-lg border-l-4 border-yellow-500 mb-6">
            <div style="display:flex;align-items:flex-start;gap:1rem">
                <span style="font-size:28px">📣</span>
                <div>
                    <h3 style="font-weight:700;color:#a16207">New Club Application Window Open!</h3>
                    <p style="color:#92400e">Submit your proposal for a new club/society before the 1st of next month.</p>
                </div>
            </div>
        </div>
    `;
    container.innerHTML = announcement + '<h3 class="text-xl font-bold text-gray-800 border-b pb-2 mb-4">Upcoming Events</h3>' + (eventHtml || '<p>No upcoming events posted yet.</p>');
}

/* ---------- PAGE-SPECIFIC INIT ---------- */
document.addEventListener('DOMContentLoaded', () => {
    bootstrapData();

    // common header logo and user info
    const headerLogoContainer = document.getElementById('header-logo-container');
    if (headerLogoContainer) headerLogoContainer.innerHTML = getLogoHtml();

    const userInfoDisplay = document.getElementById('user-info-display');
    const u = currentUser();
    if (userInfoDisplay) userInfoDisplay.textContent = u ? `${u.name.split(' ')[0]} / ${u.role.toUpperCase()}` : '';

    // Attach logout handlers
    document.querySelectorAll('.ucms-logout').forEach(btn => btn.addEventListener('click', () => {
        logout();
        window.location.href = '../index.html';
    }));

    // LOGIN page form (root login.html)
    const loginForm = document.getElementById('login-form');
    if (loginForm) {
        loginForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const id = document.getElementById('login-student_id').value.trim();
            const pw = document.getElementById('login-password').value;
            const res = login(id, pw);
            if (res.ok) {
                notify(`Logged in as ${res.user.role.toUpperCase()}`, 'success');
                // role-based redirect
                setTimeout(() => {
                    if (res.user.role === 'admin') window.location.href = 'admin/dashboard.html';
                    else window.location.href = 'student/dashboard.html';
                }, 600);
            } else {
                notify(res.message, 'error');
            }
        });
    }

    // REGISTER page
    const registerForm = document.getElementById('register-form');
    if (registerForm) {
        registerForm.addEventListener('submit', (e) => {
            e.preventDefault();
            const name = document.getElementById('register-name').value.trim();
            const id = document.getElementById('register-student_id').value.trim();
            const email = document.getElementById('register-email').value.trim();
            const password = document.getElementById('register-password').value;
            let users = getUsers();
            if (id === ADMIN_ID) { notify('Cannot register with this Student ID.', 'error'); return; }
            if (users.some(u => u.id === id || u.email === email)) { notify('Student ID or Email already exists.', 'error'); return; }
            if (password.length < 4) { notify('Password must be at least 4 characters long.', 'error'); return; }
            users.push({ id, name, email, password, role: 'student' });
            saveUsers(users);
            notify('Registration successful! Please log in.', 'success');
            setTimeout(()=> window.location.href = 'login.html', 800);
        });
    }

    /* ---------- ADMIN pages ---------- */
    // admin/clubs.html
    if (document.getElementById('admin-clubs-page')) {
        if (!requireLogin('../login.html')) return;
        if (!requireRole('admin', '../student/dashboard.html')) return;
        renderAdminClubsTable();
    }
    // admin/members.html
    if (document.getElementById('admin-members-page')) {
        if (!requireLogin('../login.html')) return;
        if (!requireRole('admin', '../student/dashboard.html')) return;
        renderAdminMembershipsTable();
    }
    // admin/events.html
    if (document.getElementById('admin-events-page')) {
        if (!requireLogin('../login.html')) return;
        if (!requireRole('admin', '../student/dashboard.html')) return;
        renderAdminEventsTable();
    }
    // admin/dashboard.html
    if (document.getElementById('admin-dashboard-page')) {
        if (!requireLogin('../login.html')) return;
        if (!requireRole('admin', '../student/dashboard.html')) return;
        renderAdminOverview();
    }

    /* ---------- STUDENT pages ---------- */
    // student/club.html
    if (document.getElementById('student-club-page')) {
        if (!requireLogin('../login.html')) return;
        if (!requireRole('student', '../admin/dashboard.html')) return;
        renderStudentClubs();
    }
    // student/membership.html
    if (document.getElementById('student-membership-page')) {
        if (!requireLogin('../login.html')) return;
        if (!requireRole('student', '../admin/dashboard.html')) return;
        renderStudentMembershipForm();
        const memForm = document.getElementById('membership-form');
        if (memForm) memForm.addEventListener('submit', handleMembershipRegistrationSubmit);
    }
    // student/event.html
    if (document.getElementById('student-event-page')) {
        if (!requireLogin('../login.html')) return;
        if (!requireRole('student', '../admin/dashboard.html')) return;
        renderStudentEvents();
        const evForm = document.getElementById('event-form');
        if (evForm) evForm.addEventListener('submit', handleEventRegistrationSubmit);
    }
    // student/output.html
    if (document.getElementById('student-output-page')) {
        if (!requireLogin('../login.html')) return;
        if (!requireRole('student', '../admin/dashboard.html')) return;
        renderStudentOutput();
    }
    // student/buzz.html
    if (document.getElementById('student-buzz-page')) {
        if (!requireLogin('../login.html')) return;
        if (!requireRole('student', '../admin/dashboard.html')) return;
        renderCampusBuzz();
    }
});
