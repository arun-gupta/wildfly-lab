echo "Converting to HTML ..."
asciidoctor -a toc -a numbered wildfly-lab.adoc
echo "done"

#echo "Converting to PDF ..."
#ruby ~/workspaces/asciidoctor-pdf/bin/asciidoctor-pdf wildfly-lab.adoc
#echo "done"
