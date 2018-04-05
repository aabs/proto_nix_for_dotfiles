function create_dotfiles_generation_2 -d "this is the function that sets up a generation of dotfiles"
    set -l new_gen (create_new_gen)
    stage_link_to_file_in_index "$PWD/dotsv1/script.v1.sh" "script.sh" $new_gen
    stage_link_to_file_in_index "$PWD/dotsv1/script2.v1.sh" "script2.sh" $new_gen
    switch_default_to_new_generation $new_gen
end

function create_dotfiles_generation_3 -d "this is the function that sets up a generation of dotfiles"
    set -l new_gen (create_new_gen)
    stage_link_to_file_in_index "$PWD/dotsv2/script.v2.sh" "script.sh" $new_gen
    stage_link_to_file_in_index "$PWD/dotsv2/script2.v2.sh" "script2.sh" $new_gen
    switch_default_to_new_generation $new_gen
end

function create_dotfiles_generation_4 -d "this is the function that sets up a generation of dotfiles"
    set -l new_gen (create_new_gen)
    stage_link_to_file_in_index "$PWD/dotsv3/script.v3.sh" "script.sh" $new_gen
    stage_link_to_file_in_index "$PWD/dotsv3/script2.v3.sh" "script2.sh" $new_gen
    switch_default_to_new_generation $new_gen
end

function setup -d "description"
    clean_up_gens
    create_links_from_home_to_default
end

function create_links_from_home_to_default -d "create the set of links in default for the first time"
    set -l def_path (get_default_path)
    link $def_path/script.sh home/script.sh
    link $def_path/script2.sh home/script2.sh
end

function clean_up_gens -d "description"
    rm -f "$PWD/home/script.sh"
    rm -f "$PWD/home/script2.sh"
    rm -rf "$GEN_ROOT/default"
    rm -rf "$GEN_ROOT/generation-1"    
    rm -rf "$GEN_ROOT/generation-2"    
    rm -rf "$GEN_ROOT/generation-3"    
end

function test1
    setup
    echo "state at the beginning"
    tree
    create_dotfiles_generation_2
    echo "state at gen 2"
    tree
    create_dotfiles_generation_3
    echo "state at gen 3"
    tree
    create_dotfiles_generation_4
    echo "state at gen 4"
    tree
end