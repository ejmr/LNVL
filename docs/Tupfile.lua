local docs = tup.glob("*.md")

tup.foreach_rule(
    docs,
    "^ Creating HTML Documentation From %f^ pandoc -s --self-contained -f markdown -t html5 -o '%o' '%f'",
    { "html/%B.html" }
)
