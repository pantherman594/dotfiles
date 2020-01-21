#!/bin/bash

HISTORY_FILE=~/.calibre_history
MULTI_FORMAT_PREFIX="(+) "

show_rofi() {
  rofi -dmenu -p "Name" \
    -i -no-custom -format i
}

if [ ! -f $HISTORY_FILE ]
then
  echo "[]" > $HISTORY_FILE
fi

select_books() {
  books=$((calibredb list -f all --for-machine --sort-by timestamp; echo "[ $(cat $HISTORY_FILE) ]" ) \
    | jq -c '(. + inputs) as $data | $data[:-1] | sort_by(.uuid as $uuid | .title as $title | $data[-1] | index($uuid) as $ind | if $ind == null then $title else $ind end)')

  if book_index=$(echo $books \
    | jq -r ".[] | \"\\(if (.formats | length) > 1 then \"$MULTI_FORMAT_PREFIX\" else \"\" end)\\(.title)\"" \
    | show_rofi); then

    book_data=$(echo $books \
      | jq -r ".[$book_index]")

    select_format "$book_data"
  fi
}

select_format() {
  book_data=$1
  formats=$(echo $book_data \
    | jq -r ".formats")
  format_suffixes=($(echo $formats \
    | jq -r "map(match(\"\\\\.[^\\\\.]+$\") | .string | .[1:]) | .[]" ))

  if [ ${#format_suffixes[@]} -gt 1 ]
  then
    if ! format_index=$(echo $formats \
      | jq -r "map(match(\"\/[^\/]+$\") | .string | .[1:]) | .[]" \
      | show_rofi);
    then
        select_books
        return 0
    fi
  else
    format_index=0
  fi

  full_path=$(echo $formats \
    | jq -r ".[$format_index]")

  book_uuid=$(echo $book_data \
    | jq -r ".uuid")

  new_history=$(jq -c "reduce .[] as \$item ([\"$book_uuid\"]; . + if \$item == \"$book_id\" then [] else [\$item] end)" $HISTORY_FILE)
  echo "$new_history" > $HISTORY_FILE

  case ${format_suffixes[$format_index],,} in
    "pdf")
      xdg-open "$full_path"
      ;;
    *)
      ebook-viewer "$full_path"
      ;;
  esac
}

select_books
