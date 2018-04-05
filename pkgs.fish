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

function get_origin_path
    echo "$GEN_ROOT/origin"
end

function ensure_default_link -d "create a default dummy link for default"
    set -l def_path (get_default_path)
    if not test -e $def_path
        switch_default_to_new_generation 0        
    end
end

function ensure_origin_generation -d "create a default dummy link for default"
    set -l op (get_origin_path)
    if not test -e $op
        mkdir -p $op
    end
end

function get_current_generation_from_target_of_default_link
    ensure_default_link
    readlink -m (get_default_path) | xargs basename | string split "-" | head -2 | tail -1
end

function switch_default_to_origin
    set -l def_path (get_default_path)
    set -l origin_path (get_origin_path)
    rm -f $def_path
    link $origin_path $def_path
end

function rollback_gen -d "switch to the previous generation"
    ensure_default_link
    ensure_origin_generation

    if test (readlink (get_default_path)) = (get_origin_path)
        echo "nowhere to roll back to"
    end

    set -l cur_gen (get_current_gen)
    set -l new_gen (math $cur_gen - 1)
    if test -e (form_index_path $new_gen)
        switch_default_to_new_generation $new_gen
    else
        if test -d (get_origin_path)
            switch_default_to_origin
        end
    end
end

function rollforward_gen -d "switch to the following generation"
    if test (readlink (get_default_path)) = (get_origin_path)
        if test -e (form_index_path 1)
            switch_default_to_new_generation 1
        end
    end
    set -l cur_gen (get_current_gen)
    set -l new_gen (math $cur_gen + 1)
    if test -e (form_index_path $new_gen)
        switch_default_to_new_generation $new_gen
    end
end

function find_all_candidate_symlinks -a root
    find $root -name "*.symlink" ! -type l
end

function stage_dotfile -a dotfile generation home_path -d "setup a dotfile link"
    ensure_default_link
    set -l x (basename -s .symlink $dotfile)
    set -l new_home_dotfile "$home_path/.$x"
    set -l target_location (form_index_path $generation)
    echo "linking $dotfile to gen $generation as $target_location/.$x"
    link $dotfile "$target_location/.$x"

    # first, if the original dotfile exists and is a regular file or directory, then first make it indirect
    if test -f $new_home_dotfile -o -d $new_home_dotfile
        make_original_file_indirect $dotfile $home_path
    end

    # since the original is now either non-existent or safely indirect, we can blow away anything in the home dir
    rm -f $new_home_dotfile
    set -l def_path (get_default_path)
    link "$def_path/.$x" $new_home_dotfile
end

# search below for files matching a pattern and create a new generation from them transforming them to match dotfile format
function stage_matching_files_as_dotfiles -a root gen -d "create a generation of new dotfiles for all matching sub-files"
    set -l matching_files (find_all_candidate_symlinks "$root")
    for sl in $matching_files
        stage_dotfile $sl $gen "$PWD/home"
    end
end

function make_original_file_indirect -a dotfile home_path -d "description"
    ensure_origin_generation
    set -l origin_gen (get_origin_path)
    set -l x (basename -s .symlink $dotfile)
    set -l original_dotfile "$home_path/.$x"
    if test -e $original_dotfile -a ! -L $original_dotfile
        echo "moving $original_dotfile => $origin_gen/.$x"
        mv $original_dotfile "$origin_gen/.$x"
        link "$origin_gen/.$x" $original_dotfile
    else
        echo "not moving $original_dotfile => $origin_gen/.$x"
    end
end

function make_matching_originals_indirect -a root -d "move original symlink targets into a special area for preservation"
    set -l matching_files (find_all_candidate_symlinks "$root")
    for sl in $matching_files
        make_original_file_indirect $sl "$PWD/home"
    end
    
end

# THE PLAN
# 0. create current generation link  generationC
# 0. define links in root in terms of generationC
# 1. Create a new folder GenerationX
# 2. Create links in generationX to all files in origin dir
# 4. redirect generationC to be a link to generationX
# 5. now all links defined as $generationC/blah.ext should point to $generationX/blah.ext which is in turn a link to $origin/blah.ext


# P1: final rollback destination is the origin, after which rollbacks stop changing things