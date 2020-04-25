read -p "Continue (y/n)? " choice
case "${choice}" in
  [yY]|[yY][eE][sS] )
    echo "yes"
    ;;
  [nN]|[nN][oO] )
    echo "no"
    ;;
  * )
    echo "invalid"
    ;;
esac
