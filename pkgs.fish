#!/usr/bin/env bash
set -x GEN_ROOT /mnt/d/Synchronised/active_personal/Projects/by-technology/shell/prototypes/atomic_linkage/gens
set -x CURRENT_GEN 1

function link -a original_file symlink
    ln -sf $original_file $symlink
end

function form_index_path -a index
    echo $GEN_ROOT/generation-$index/
end

function make_gen -a index
    set -l new_gen (form_index_path $index)
    mkdir -p $new_gen
    echo $new_gen
end

function stage_link_to_file_in_index -a path_to_file new_name index
    set -l base (form_index_path $index)
    # set -l name (basename $path_to_file)
    link $path_to_file "$base/$new_name"
end

function create_default_link -a original_path target_location
    # original path is the name of the thing (e.g.  /a/b/c/blah.ext)
    # target_location is where the link is to be created (e.g. $HOME)
    set -l name (basename $original_path)
    set -l default_location $GEN_ROOT/default/$name
    link $target_location/$name $default_location
    # this creates a link in target location to somewhere in default
end

function switch_default_to_new_generation -a new_gen
    set -l new_gen_path (form_index_path $new_gen)
    echo "switching gens to '$new_gen_path'"
    rm -f "$GEN_ROOT/default"
    link "$new_gen_path" "$GEN_ROOT/default"
    set -x CURRENT_GEN $new_gen
end

function create_links_from_home_to_default -d "create the set of links in default for the first time"
    link $GEN_ROOT/default/script.sh home/script.sh
    link $GEN_ROOT/default/script2.sh home/script2.sh
end

function create_dotfiles_generation_2 -d "this is the function that sets up a generation of dotfiles"
    if not test -e "home/script.sh"
        create_links_from_home_to_default
    end

    set -l new_gen (math $CURRENT_GEN + 1)
    set -l new_gen_path (make_gen $new_gen)
    echo "creating gen $new_gen at $new_gen_path"
    stage_link_to_file_in_index "$PWD/dotsv1/script.v1.sh" "script.sh" $new_gen
    stage_link_to_file_in_index "$PWD/dotsv1/script2.v1.sh" "script2.sh" $new_gen
    switch_default_to_new_generation $new_gen
end

function create_dotfiles_generation_3 -d "this is the function that sets up a generation of dotfiles"
    if not test -e "home/script.sh"
        create_links_from_home_to_default
    end

    set -l new_gen (math $CURRENT_GEN + 1)
    set -l new_gen_path (make_gen $new_gen)
    echo "creating v2 gen $new_gen at $new_gen_path"
    stage_link_to_file_in_index "$PWD/dotsv2/script.v2.sh" "script.sh" $new_gen
    stage_link_to_file_in_index "$PWD/dotsv2/script2.v2.sh" "script2.sh" $new_gen
    switch_default_to_new_generation $new_gen
end

function create_dotfiles_generation_4 -d "this is the function that sets up a generation of dotfiles"
    if not test -e "home/script.sh"
        create_links_from_home_to_default
    end

    set -l new_gen (math $CURRENT_GEN + 1)
    set -l new_gen_path (make_gen $new_gen)
    echo "creating v2 gen $new_gen at $new_gen_path"
    stage_link_to_file_in_index "$PWD/dotsv3/script.v3.sh" "script.sh" $new_gen
    stage_link_to_file_in_index "$PWD/dotsv3/script2.v3.sh" "script2.sh" $new_gen
    switch_default_to_new_generation $new_gen
end

function clean_up_gens -d "description"
    rm -f "$PWD/home/script.sh"
    rm -f "$PWD/home/script2.sh"
    rm -rf "$GEN_ROOT/default"
    rm -rf "$GEN_ROOT/generation-2"    
    rm -rf "$GEN_ROOT/generation-3"    
    rm -rf "$GEN_ROOT/generation-4"    
end
# THE PLAN
# 0. create current generation link  generationC
# 0. define links in root in terms of generationC
# 1. Create a new folder GenerationX
# 2. Create links in generationX to all files in origin dir
# 4. redirect generationC to be a link to generationX
# 5. now all links defined as $generationC/blah.ext should point to $generationX/blah.ext which is in turn a link to $origin/blah.ext
