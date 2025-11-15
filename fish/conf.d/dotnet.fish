# Set DOTNET_ROOT if not already set
if test -z "$DOTNET_ROOT"
    set -gx DOTNET_ROOT "$HOME/.dotnet"
end

# Add dotnet to PATH if not already present
if not contains "$DOTNET_ROOT" $PATH
    set -gx PATH $PATH "$DOTNET_ROOT"
end

# Set and add .NET tools path
set -gx DOTNET_TOOLS_PATH "$HOME/.dotnet/tools"
if not contains "$DOTNET_TOOLS_PATH" $PATH
    set -gx PATH $PATH "$DOTNET_TOOLS_PATH"
end

# Set bundle extraction directory (for self-contained apps)
if test -z "$DOTNET_BUNDLE_EXTRACT_BASE_DIR"
    set -gx XDG_CACHE_HOME (test -z "$XDG_CACHE_HOME"; and echo "$HOME/.cache" || echo "$XDG_CACHE_HOME")
    set -gx DOTNET_BUNDLE_EXTRACT_BASE_DIR "$XDG_CACHE_HOME/dotnet_bundle_extract"
end
