# RottenPotatoes — HW3: BDD & Cucumber

Aplicação **Rotten Potatoes** (Rails 7.1.2 / Ruby 3.2.2) usada como base para o **Homework 3** de *Engineering Long-Lasting Software*. O objetivo é cobrir, com cenários **Cucumber**, os *happy paths* das partes 1 a 3 do HW2 (ordenar e filtrar filmes), aplicando os princípios de BDD: cenários declarativos, passos reutilizáveis e foco em comportamento, não em interação de baixo nível.

---

## Sumário

- [Stack](#stack)
- [Como rodar](#como-rodar)
- [Como rodar os testes BDD](#como-rodar-os-testes-bdd)
- [Questões resolvidas](#questões-resolvidas)
  - [Parte 1 — Passo declarativo para popular filmes](#parte-1--passo-declarativo-para-popular-filmes)
  - [Parte 2 — Cenários de filtro por classificação MPAA](#parte-2--cenários-de-filtro-por-classificação-mpaa)
  - [Parte 3 — Cenários de ordenação por título e data](#parte-3--cenários-de-ordenação-por-título-e-data)
- [Saída dos testes (todos verdes)](#saída-dos-testes-todos-verdes)
- [Estrutura de arquivos relevantes](#estrutura-de-arquivos-relevantes)

---

## Stack

| Camada | Versão |
|---|---|
| Ruby | 3.2.2 |
| Rails | 7.1.2 |
| Banco | SQLite 3 |
| BDD | cucumber-rails ~> 3.0 |
| Browser sim. | Capybara (driver `:rack_test`) |
| Isolamento de DB | database_cleaner-active_record |
| Asserções | rspec-expectations |

---

## Como rodar

```bash
bundle install
bin/rails db:create db:migrate
bin/rails server          # http://localhost:3000/movies
```

Funcionalidades disponíveis em `/movies`:

- Listagem com colunas **Movie Title** e **Release Date** clicáveis (ordenação).
- Caixas de seleção **G / PG / PG-13 / R** + botão **Refresh** (filtro por classificação MPAA).
- CRUD completo de filmes (Adicionar / Editar / Excluir).

---

## Como rodar os testes BDD

```bash
RAILS_ENV=test bin/rails db:drop db:create db:schema:load
bundle exec cucumber                                     # toda a suíte
bundle exec cucumber features/sort_movie_list.feature    # só sort
bundle exec cucumber features/filter_movie_list.feature  # só filter
```

---

## Questões resolvidas

### Parte 1 — Passo declarativo para popular filmes

> O passo `Given the following movies exist` deve popular o banco **sem** ir pela GUI, já que adicionar filmes não é o foco dos cenários (princípio BDD da Seção 4.7).

Implementado em `features/step_definitions/movie_steps.rb` usando ActiveRecord direto:

```ruby
Given /^the following movies exist:?$/ do |movies_table|
  movies_table.hashes.each do |row|
    Movie.create!(
      title: row['title'],
      rating: row['rating'],
      release_date: Date.parse(row['release_date']),
      description: row['description']
    )
  end
end
```

**Critério de sucesso:** Background de `filter_movie_list.feature` e `sort_movie_list.feature` ambos verdes. ✅

### Parte 2 — Cenários de filtro por classificação MPAA

**(a) "restrict to movies with 'PG' or 'R' ratings"** — definido em `features/filter_movie_list.feature:24`. Marca PG/R, desmarca G/PG-13, valida que aparecem 5 filmes e somem 5.

**(b) Passo agrupador `When I check the following ratings: G, PG, R`** — definido em `movie_steps.rb`:

```ruby
When /^I check the following ratings: (.*)$/ do |rating_list|
  rating_list.split(/\s*,\s*/).each do |rating|
    step %(I check "ratings_#{rating}")
  end
end
```

Reutiliza o passo `check` do `web_steps.rb` (DICA da Seção 4.7). Há também a versão `uncheck`.

**(c) Passo agregador `Then I should see all of the movies`** — em vez de listar 10 `And I should see ...`, conta linhas da tabela contra `Movie.count`:

```ruby
Then /^I should see all of the movies$/ do
  rows = page.all('table#movies tbody tr').count
  expect(rows).to eq(Movie.count)
end
```

**(d) Cenário "all ratings selected"** — definido em `filter_movie_list.feature:39` usando os passos das partes (b) e (c).

> O cenário "no ratings selected" foi **dispensado** pelo enunciado.

**Critério de sucesso:** todos os cenários de `filter_movie_list.feature` verdes. ✅

### Parte 3 — Cenários de ordenação por título e data

**(a) Passo `Then I should see "X" before "Y"`** — verifica a ordem com regex em `page.body`:

```ruby
Then /^I should see "([^"]+)" before "([^"]+)"$/ do |first, second|
  expect(page.body).to match(/#{Regexp.escape(first)}.*#{Regexp.escape(second)}/m)
end
```

**(b) Cenários "sort movies alphabetically" e "sort movies in increasing order of release date"** — em `sort_movie_list.feature:26-31`, usando o passo da parte (a):

- `Then I should see "Aladdin" before "Amelie"`
- `Then I should see "2001: A Space Odyssey" before "The Incredibles"`

**Critério de sucesso:** todos os cenários de `sort_movie_list.feature` verdes. ✅

---

## Saída dos testes (todos verdes)

Comando executado:

```bash
$ bundle exec cucumber --format progress
```

```
Using the default profile...
................................

4 scenarios (4 passed)
32 steps (32 passed)
0m0.230s
```

Detalhamento por cenário (`bundle exec cucumber`):

| # | Feature | Cenário | Resultado |
|---|---|---|---|
| 1 | `filter_movie_list.feature` | restrict to movies with 'PG' or 'R' ratings | ✅ passed |
| 2 | `filter_movie_list.feature` | all ratings selected | ✅ passed |
| 3 | `sort_movie_list.feature` | sort movies alphabetically | ✅ passed |
| 4 | `sort_movie_list.feature` | sort movies in increasing order of release date | ✅ passed |

**Total: 4 cenários, 32 steps, 0 falhas, 0 pendentes.**

---

## Estrutura de arquivos relevantes

```
rottenpotatoes/
├── app/
│   ├── controllers/
│   │   └── movies_controller.rb          # action index com filtro + sort
│   ├── models/
│   │   └── movie.rb
│   └── views/movies/
│       └── index.html.erb                # form de ratings + tabela
├── features/
│   ├── filter_movie_list.feature         # 2 cenários (PG+R, all)
│   ├── sort_movie_list.feature           # 2 cenários (título, data)
│   ├── step_definitions/
│   │   ├── movie_steps.rb                # passos custom HW3 (partes 1-3)
│   │   └── web_steps.rb                  # passos genéricos Capybara
│   └── support/
│       ├── capybara.rb                   # driver :rack_test
│       ├── env.rb                        # boot do cucumber-rails + DatabaseCleaner
│       └── paths.rb                      # "the RottenPotatoes home page" → movies_path
├── config/
│   └── cucumber.yml                      # perfis default/wip/rerun
└── Gemfile                               # cucumber-rails + dependências de teste
```
