@echo off

echo delete PokeBases.db
del PokeBases.db

python pokemon_from_csv.py csv\pokemon_species.csv csv\pokemon_species_names.csv csv\pokemon_abilities.csv csv\pokemon_moves.csv csv\pokemon_stats.csv csv\pokemon_types.csv csv\pokemon_game_indices.csv csv\pokemon.csv csv\pokemon_forms.csv csv\pokemon_form_names.csv csv\pokemon_egg_groups.csv

pause
