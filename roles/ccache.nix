{ ... }:

{
  # This enables compilation cache via ccacheStdenv.
  # WARNING: /var/cache/ccache needs to exist + nixbld group
   nixpkgs.overlays = [ (self: super: {
     ccacheWrapper = super.ccacheWrapper.override {
       extraConfig = ''
         export CCACHE_COMPRESS=1
         export CCACHE_DIR=/var/cache/ccache
         export CCACHE_UMASK=007
       '';
     };
   }) ];
}
