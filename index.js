const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const app = express();
const port = 3000;

app.use(express.json());

// Conecta no banco
const db = new sqlite3.Database(path.join(__dirname, 'db', 'meubanco.db'), (err) => {
    if (err) return console.error('Erro ao conectar:', err.message);
    console.log('Conectado ao banco SQLite.');
});

// Cria a tabela se não existir
db.run(`CREATE TABLE IF NOT EXISTS financa (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    valor REAL NOT NULL,
    data TEXT NOT NULL,
    isIncome INTEGER NOT NULL
)`);

// POST: recebe dados do formulário e insere no banco
app.post('/', (req, res) => {
    const { title, value, date, isIncome } = req.body;

    if (!title || typeof value !== 'number' || !date || typeof isIncome !== 'boolean') {
        return res.status(400).json({ error: 'Campos obrigatórios: title, value, date, isIncome (boolean)' });
    }


    const query = `INSERT INTO financa (title, valor, data, isIncome) VALUES (?, ?, ?, ?)`;
    db.run(query, [title, value, date, isIncome ], function (err) {
        if (err) return res.status(500).json({ error: err.message });

        console.log('Nova entrada inserida:', { id: this.lastID, title, value, date });
        res.status(201).json({
            success: true,
            message: 'Transação salva com sucesso!',
            id: this.lastID
        });
    });
});

// GET: lista os dados do banco
app.get('/', (req, res) => {
    db.all('SELECT * FROM financa', [], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });

        const data = rows.map(r => ({
            ...r,
            isIncome: !!r.isIncome // converte 0/1 para false/true
        }));

        res.json(data);
    });
});

// Inicia o servidor
app.listen(port, () => {
    console.log(`Servidor rodando em http://localhost:${port}`);
});
