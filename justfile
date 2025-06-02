deploy:
  deploy

bootstrap device mode="prompt":
  #!/usr/bin/env sh
  if [ "{{mode}}" == "yes" ]; then
    # Refresh sudo credentials if necessary.
    sudo -v
  fi

  store_path=$(nix build .#bootstrap --print-out-paths)
  iso_path_files=("$store_path/iso/nixos-"*.iso)
  iso_path="${iso_path_files[0]}"
  if [ ! -f "$iso_path" ]; then
    echo "could not find bootstrap iso in store path $iso_path"
    exit 1
  fi

  unset write
  if [ "{{mode}}" == "yes" ]; then
    write=1
  else
    echo "Do you want to write $iso_path to {{device}}? (y/N)"
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      write=1
    fi
  fi

  if [ -n "$write" ]; then
    echo "writing to device..."
    sudo dd bs=4M if="$iso_path" of="{{device}}" status=progress conv=fsync
  else
    echo "cancelled"
  fi
