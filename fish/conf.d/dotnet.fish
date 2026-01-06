# .NET SDK Environment Setup for Fish Shell

# Set DOTNET_ROOT if not already defined
if test -z "$DOTNET_ROOT"
    set -gx DOTNET_ROOT "$HOME/.dotnet"
end

# Safely add dotnet to PATH (no duplicates)
if not contains "$DOTNET_ROOT" $PATH
    set -gx PATH $PATH "$DOTNET_ROOT"
end

# Add .NET global tools path
set -gx DOTNET_TOOLS_PATH "$HOME/.dotnet/tools"
if not contains "$DOTNET_TOOLS_PATH" $PATH
    set -gx PATH $PATH "$DOTNET_TOOLS_PATH"
end

# Use user-specific cache for bundle extraction
if test -z "$DOTNET_BUNDLE_EXTRACT_BASE_DIR"
    set -gx XDG_CACHE_HOME (test -z "$XDG_CACHE_HOME"; and echo "$HOME/.cache" || echo "$XDG_CACHE_HOME")
    set -gx DOTNET_BUNDLE_EXTRACT_BASE_DIR "$XDG_CACHE_HOME/dotnet_bundle_extract"
end

