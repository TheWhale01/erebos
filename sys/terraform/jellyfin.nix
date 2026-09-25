{ ... }:

{
  resource = {
    authentik_group.jellyfin_admins = {
      name = "jellyfin-admins";
      users = [
        "\${data.authentik_user.whale.id}"
      ];
      is_superuser = false;
    };
  };
}
