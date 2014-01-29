echo "Converting to HTML ..."
asciidoctor -a toc -a numbered wildfly-lab.adoc
echo "done"

echo "Converting to DocBook ..."
asciidoctor -b docbook -a toc -a numbered -d book wildfly-lab.adoc
echo "done"

echo "Converting to PDF ..."
~/tools/asciidoctor-fopub/fopub wildfly-lab.xml
echo "done"

## Giving error https://github.com/opendevise/asciidoctor-pdf/issues/3
#echo "Converting to PDF ..."
#ruby ~/workspaces/asciidoctor-pdf/bin/asciidoctor-pdf wildfly-lab.adoc
#echo "done"
