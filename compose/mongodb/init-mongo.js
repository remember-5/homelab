// Connect to the admin database and create a user.
db.getSiblingDB('admin').createUser({
    user: 'root',
    pwd: '123456',
    roles: [{ role: 'root', db: 'admin' }],
});
