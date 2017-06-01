# Another solution without getopt[s], POSIX, old Unix style; re: http://stackoverflow.com/a/33191693/1397555

#!/bin/sh

echo
echo "POSIX-compliant getopt(s)-free old-style-supporting option parser from phk@[se.unix]"
echo

print_usage() {
  echo "Usage:

  $0 {a|b|c} [ARG...]

Options:

  --aaa-0-args
  -a
    Option without arguments.

  --bbb-1-args ARG
  -b ARG
    Option with one argument.

  --ccc-2-args ARG1 ARG2
  -c ARG1 ARG2
    Option with two arguments.

" >&2
}

if [ $# -le 0 ]; then
  print_usage
  exit 1
fi

opt=
while :; do

  if [ $# -le 0 ]; then

    # no parameters remaining -> end option parsing
    break

  elif [ ! "$opt" ]; then

    # we are at the beginning of a fresh block
    # remove optional leading hyphen and strip trailing whitespaces
    opt=$(echo "$1" | sed 's/^-\?\([a-zA-Z0-9\?-]*\)/\1/')

  fi

  # get the first character -> check whether long option
  first_chr=$(echo "$opt" | awk '{print substr($1, 1, 1)}')
  [ "$first_chr" = - ] && long_option=T || long_option=F

  # note to write the options here with a leading hyphen less
  # also do not forget to end short options with a star
  case $opt in

    -)

      # end of options
      shift
      break
      ;;

    a*|-aaa-0-args)

      echo "Option AAA activated!"
      ;;

    b*|-bbb-1-args)

      if [ "$2" ]; then
        echo "Option BBB with argument '$2' activated!"
        shift
      else
        echo "BBB parameters incomplete!" >&2
        print_usage
        exit 1
      fi
      ;;

    c*|-ccc-2-args)

      if [ "$2" ] && [ "$3" ]; then
        echo "Option CCC with arguments '$2' and '$3' activated!"
        shift 2
      else
        echo "CCC parameters incomplete!" >&2
        print_usage
        exit 1
      fi
      ;;

    h*|\?*|-help)

      print_usage
      exit 0
      ;;

    *)

      if [ "$long_option" = T ]; then
        opt=$(echo "$opt" | awk '{print substr($1, 2)}')
      else
        opt=$first_chr
      fi
      printf 'Error: Unknown option: "%s"\n' "$opt" >&2
      print_usage
      exit 1
      ;;

  esac

  if [ "$long_option" = T ]; then

    # if we had a long option then we are going to get a new block next
    shift
    opt=

  else

    # if we had a short option then just move to the next character
    opt=$(echo "$opt" | awk '{print substr($1, 2)}')

    # if block is now empty then shift to the next one
    [ "$opt" ] || shift

  fi

done

echo "Doing something..."

exit 0