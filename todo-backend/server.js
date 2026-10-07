const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('./db');
const verifyToken = require('./middleware/auth');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// --- AUTH ROUTES ---

// Register
app.post('/api/auth/register', async (req, res) => {
  const { username, password } = req.body;
  try {
    const userCheck = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
    if (userCheck.rows.length > 0) {
      return res.status(400).json({ message: 'Username already exists' });
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const newUser = await pool.query(
      'INSERT INTO users (username, password) VALUES ($1, $2) RETURNING id, username',
      [username, hashedPassword]
    );

    const token = jwt.sign({ id: newUser.rows[0].id }, process.env.JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, user: newUser.rows[0] });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Login
app.post('/api/auth/login', async (req, res) => {
  const { username, password } = req.body;
  try {
    const user = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
    if (user.rows.length === 0) {
      return res.status(400).json({ message: 'Invalid Credentials' });
    }

    const validPassword = await bcrypt.compare(password, user.rows[0].password);
    if (!validPassword) {
      return res.status(400).json({ message: 'Invalid Credentials' });
    }

    const token = jwt.sign({ id: user.rows[0].id }, process.env.JWT_SECRET, { expiresIn: '7d' });
    res.json({ token, user: { id: user.rows[0].id, username: user.rows[0].username } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Ensure reminder_at column exists in database
pool.query('ALTER TABLE todos ADD COLUMN IF NOT EXISTS reminder_at TIMESTAMPTZ;').catch(err => {
  console.log('Database init notice:', err.message);
});

// --- TODO ROUTES ---

// Get all todos for logged-in user
app.get('/api/todos', verifyToken, async (req, res) => {
  try {
    const todos = await pool.query('SELECT * FROM todos WHERE user_id = $1 ORDER BY id DESC', [req.user.id]);
    res.json(todos.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create todo
app.post('/api/todos', verifyToken, async (req, res) => {
  const { title, reminder_at } = req.body;
  try {
    const newTodo = await pool.query(
      'INSERT INTO todos (user_id, title, reminder_at) VALUES ($1, $2, $3) RETURNING *',
      [req.user.id, title, reminder_at || null]
    );
    res.json(newTodo.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update todo (completion, reminder_at)
app.put('/api/todos/:id', verifyToken, async (req, res) => {
  const { id } = req.params;
  const { is_completed, reminder_at } = req.body;
  try {
    const updates = [];
    const values = [];

    if (is_completed !== undefined) {
      values.push(is_completed);
      updates.push(`is_completed = $${values.length}`);
    }

    if (reminder_at !== undefined) {
      values.push(reminder_at);
      updates.push(`reminder_at = $${values.length}`);
    }

    if (updates.length === 0) {
      return res.status(400).json({ message: 'No fields provided to update' });
    }

    values.push(id, req.user.id);
    const idIdx = values.length - 1;
    const userIdx = values.length;

    const query = `UPDATE todos SET ${updates.join(', ')} WHERE id = $${idIdx} AND user_id = $${userIdx} RETURNING *`;
    const updatedTodo = await pool.query(query, values);

    if (updatedTodo.rows.length === 0) {
      return res.status(404).json({ message: 'Todo not found' });
    }
    res.json(updatedTodo.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete todo
app.delete('/api/todos/:id', verifyToken, async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM todos WHERE id = $1 AND user_id = $2', [id, req.user.id]);
    res.json({ message: 'Todo deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));