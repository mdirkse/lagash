function default-niri-layout --description 'Move app windows to their default niri monitors and workspaces'
    # Slack   -> eDP-1 workspace 1 (maximized)
    # Spotify -> eDP-1 workspace 2 (maximized)
    # VS Code -> DP-1   workspace 2
    # Outlook -> DP-1   workspace 3
    # Teams   -> DP-1   workspace 3

    set -l laptop_output eDP-1
    set -l desktop_output DP-1

    function __default_niri_layout_find_window_id --argument-names pattern
        niri msg -j windows | jq -r --arg p $pattern '
            [.[] | select(
                (.app_id // "" | test($p; "i")) or
                (.title // "" | test($p; "i"))
            )] | first | .id // empty
        '
    end

    function __default_niri_layout_find_window_id_by_title_and_app_id --argument-names title_pattern app_id_pattern
        niri msg -j windows | jq -r --arg t $title_pattern --arg a $app_id_pattern '
            [.[] | select(
                (.title // "" | test($t)) and
                (.app_id // "" | test($a))
            )] | first | .id // empty
        '
    end

    function __default_niri_layout_maximize_window --argument-names window_id
        if test -z "$window_id"
            return 1
        end

        niri msg action focus-window --id $window_id
        niri msg action maximize-column
        niri msg action maximize-window-to-edges --id $window_id
    end

    function __default_niri_layout_move_window_to_output_workspace --argument-names window_id workspace_idx output
        if test -z "$window_id"
            return 1
        end

        # Workspace indices are relative to the focused monitor.
        niri msg action focus-monitor $output
        niri msg action move-window-to-monitor --id $window_id $output
        niri msg action move-window-to-workspace --window-id $window_id --focus false $workspace_idx
    end

    function __default_niri_layout_move_and_maximize_window --argument-names window_id workspace_idx output
        __default_niri_layout_move_window_to_output_workspace $window_id $workspace_idx $output
        __default_niri_layout_maximize_window $window_id
    end

    function __default_niri_layout_cleanup
        functions -e __default_niri_layout_find_window_id
        functions -e __default_niri_layout_find_window_id_by_title_and_app_id
        functions -e __default_niri_layout_maximize_window
        functions -e __default_niri_layout_move_window_to_output_workspace
        functions -e __default_niri_layout_move_and_maximize_window
        functions -e __default_niri_layout_cleanup
    end

    set -l slack_id (__default_niri_layout_find_window_id '^slack$')
    set -l spotify_id (__default_niri_layout_find_window_id '^spotify$')
    set -l vscode_id (__default_niri_layout_find_window_id '^jumbo - Visual Studio Code$')
    set -l outlook_id (__default_niri_layout_find_window_id_by_title_and_app_id '^Outlook \(PWA\)' '^chrome-')
    set -l teams_id (__default_niri_layout_find_window_id_by_title_and_app_id '^Microsoft Teams \(PWA\)' '^chrome-')

    set -l missing
    if test -z "$slack_id"
        set -a missing Slack
    end
    if test -z "$spotify_id"
        set -a missing Spotify
    end
    if test -z "$vscode_id"
        set -a missing 'VS Code (jumbo)'
    end
    if test -z "$outlook_id"
        set -a missing 'Outlook (PWA)'
    end
    if test -z "$teams_id"
        set -a missing 'Microsoft Teams (PWA)'
    end

    if test (count $missing) -gt 0
        echo "Window(s) not found: "(string join ', ' $missing) >&2
        echo "Open them first, or inspect with: niri msg -j windows" >&2
        __default_niri_layout_cleanup
        return 1
    end

    __default_niri_layout_move_and_maximize_window $slack_id 1 $laptop_output
    __default_niri_layout_move_and_maximize_window $spotify_id 2 $laptop_output
    __default_niri_layout_move_window_to_output_workspace $vscode_id 2 $desktop_output
    __default_niri_layout_move_window_to_output_workspace $outlook_id 3 $desktop_output
    __default_niri_layout_move_window_to_output_workspace $teams_id 3 $desktop_output

    echo "Moved Slack and Spotify to $laptop_output (workspaces 1-2, maximized), VS Code to $desktop_output workspace 2, and Outlook and Teams to $desktop_output workspace 3."
    __default_niri_layout_cleanup
end
