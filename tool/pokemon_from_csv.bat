@echo off

echo delete PokeBases.db
del PokeBases.db

python pokemon_from_csv.py pokeapi\data\v2\csv\pokemon_species.csv pokeapi\data\v2\csv\pokemon_species_names.csv pokeapi\data\v2\csv\pokemon_abilities.csv pokeapi\data\v2\csv\pokemon_moves.csv pokeapi\data\v2\csv\pokemon_stats.csv pokeapi\data\v2\csv\pokemon_types.csv pokeapi\data\v2\csv\pokemon_game_indices.csv pokeapi\data\v2\csv\pokemon.csv pokeapi\data\v2\csv\pokemon_forms.csv pokeapi\data\v2\csv\pokemon_form_names.csv pokeapi\data\v2\csv\pokemon_egg_groups.csv

pause
