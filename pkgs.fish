#!/usr/bin/env bash
set -x GEN_ROOT /mnt/d/Synchronised/active_personal/Projects/by-technology/shell/prototypes/atomic_linkage/gens

function link -a original_file symlink
    ln -fs $original_file $symlink
end

function form_index_path -a index
    echo $GEN_ROOT/generation-$index/
end

function stage_link_to_file_in_index -a path_to_file new_name index
    set -l base (form_index_path $index)
    # set -l name (basename $path_to_file)
    link $path_to_file "$base/$new_name"
end

function create_default_link -a original_path target_location
    # original path is the name of the thing (e.g.  /a/b/c/blah.ext)
    # target_location is where the link is to be created (e.g. $HOME)
    ensure_default_link
    set -l def_path (get_default_path)
    set -l name (basename $original_path)
    link $target_location/$name "$def_path/$name"
    # this creates a link in target location to somewhere in default
end

function create_new_gen -d "create a new generation folder and return gen index"
    ensure_default_link
    set -l current_gen (get_current_gen)
    set -l new_gen (math $current_gen + 1)
    set -l new_gen_path (form_index_path $new_gen)
    mkdir -p $new_gen_path
    echo $new_gen
end

function switch_default_to_new_generation -a new_gen
    # would cause infinite recursion: ensure_default_link
    set -l def_path (get_default_path)
    set -l new_gen_path (form_index_path $new_gen)
    rm -f $def_path
    link "$new_gen_path" $def_path
end

function get_current_gen
    ensure_default_link
    echo (get_current_generation_from_target_of_default_link)
end

function get_default_path
    echo "$GEN_ROOT/default"
end

function ensure_default_link -d "create a default dummy link for default"
    set -l def_path (get_default_path)
    if not test -e $def_path
        switch_default_to_new_generation 0        
    end
end

function get_current_generation_from_target_of_default_link
    ensure_default_link
    readlink -m (get_default_path) | xargs basename | string split "-" | head -2 | tail -1
end

# search below for files matching a pattern and create a new generation from them transforming them to match dotfile format
function stage_matching_files_as_dotfiles -d "create a generation of new dotfiles for all matching sub-files"
    set matching_files (find . -name "*.symlink")
end

function rollback_gen -d "switch to the previous generation"
    set -l cur_gen (get_current_gen)
    set -l new_gen (math $cur_gen - 1)
    if test -e (form_index_path $new_gen)
        switch_default_to_new_generation $new_gen
    end
end

function rollforward_gen -d "switch to the following generation"
    set -l cur_gen (get_current_gen)
    set -l new_gen (math $cur_gen + 1)
    if test -e (form_index_path $new_gen)
        switch_default_to_new_generation $new_gen
    end
end
# THE PLAN
# 0. create current generation link  generationC
# 0. define links in root in terms of generationC
# 1. Create a new folder GenerationX
# 2. Create links in generationX to all files in origin dir
# 4. redirect generationC to be a link to generationX
# 5. now all links defined as $generationC/blah.ext should point to $generationX/blah.ext which is in turn a link to $origin/blah.ext
