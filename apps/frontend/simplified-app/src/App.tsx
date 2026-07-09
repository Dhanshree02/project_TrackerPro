import React from 'react'

export default function App() {
  return (
    <div className="app-root">
      <aside className="sidebar">
        <div className="brand">P · Project Compass</div>
        <nav>
          <a href="/">Dashboard</a>
          <a href="/clients">Clients</a>
          <a href="/projects">Projects</a>
        </nav>
      </aside>
      <main className="main">
        <header>
          <h1>Welcome back, Aarav</h1>
          <p>Minimal simplified dashboard — running locally</p>
        </header>
        <section className="cards">
          <div className="card">Ongoing<br/><strong>4</strong></div>
          <div className="card">At Risk<br/><strong>3</strong></div>
          <div className="card">Pending<br/><strong>2</strong></div>
        </section>
      </main>
    </div>
  )
}
