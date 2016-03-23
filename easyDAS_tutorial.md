# easyDAS Tutorial #

easyDAS in a web application to create DAS sources. Biological data can be uploaded to easyDAS in various formats including GFF and Tabular files and a new DAS source will be automatically created. This source can then be used in any of the available DAS clients such as Ensembl, Dasty and registered to the DAS registry so anyone can use it.
Content

## Create your own DAS data source ##

In this tutorial we will create a DAS data source from a GFF file containing gene data.

### Before we begin ###
  * Download the data file (http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/genes.gff) and store it in your computer. You will need it later.

  * Go to http://www.ebi.ac.uk/panda-srv/easydas/ You will see something like this. A page containing a list of the publicly available sources in easyDAS.

![http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/easyDAS1.png](http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/easyDAS1.png)

  * It is possible to use easyDAS to create DAS sources as an anonymous user. That means, without telling easyDAS anything about you. However, since easyDAS cannot know if you are the real author of a DAS source, it is not possible to change, update or delete a source created as an anonymous user. Additionally, those sources will be automatically deleted after some time.

A registered user, in contrast, can modify, update and delete his sources and can create private source not listed in the general sources listing. Registering is simple and only an email address is required.
How to create a source

Click on **Login** on the top right corner to start the registration process.

Fill in the form as in the image (changing the email address, etc...) and click on **Register**.

The **Server Name** field corresponds to the name you want for your own das server and will be part of the URL of your sources.

![http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/register.png](http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/register.png)

### Create a source ###
  * You will see an empty list of sources. Let's create one source. Click on the **Create a new source** button. This will start the source creation wizard, so prepare for some next, next, next...

  * The first step on the source creation process it uploading the data file. Click on **Browse** and select the file **genes.gff** you downloaded before. Click on **Upload** to actually upload the file onto the system.

  * A dialog with a preview of the detected file format and a preview of how your data will be used is shown. Since it's a standard GFF file, the systems detects it correctly and knows how to handle it.

> ![http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/wiz_file.png](http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/wiz_file.png)

### Source description ###

  * Once you click on next to accept the detected format, you will see a dialog asking you the basic information about the source (it's name, description, etc...) Fill in the form as shown.

![http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/wiz_source.png](http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/wiz_source.png)

  * On this dialog, there's a very important part called **Coordinates System**. This is where we can state which are the sequences we are annotating (species, assembly, etc). Click on the little magnifier and select, on the dialog appearing, the last assembly of the human genome (this is wahat our genes are annotating). While it's not necessary to select a coordinate system to create a DAS source, it is required by most of the clients and will make any further integration much easier.
> Click on "Next" when done.

![http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/wiz_coord.png](http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/wiz_coord.png)

### Mapping our data to DAS concepts ###

  * On this screen we can map every field on our data file onto zero or more DAS concepts (id, start, end, etc...). Since we are using a GFF file, the semantics of every field is already known. We won't need to make any adaptation on this form right now. If you want an explanation of every DAS concept, click on **Help**.

![http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/wiz_map.png](http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/wiz_map.png)

  * At this point, the finish button is enabled and the source could be created. click on "Next" to refine the source definition.

  * Skip the defaults dialog. It allows the definition of sensible default values for any missing field.

### Ontology mapping ###

  * In this screen, ontology terms can be assigned to the type identifiers. This will enrich your data and add semantics to it. The DAS registry and some clients can take advantage of this information and a correct ontology mapping will make your data more valuable.

> Click on the magnifier for every type and select a sensible term either using the search interface or the ontology browser.

  * OTE:**For the**gene**type, select "gene, SO:0000704". This will be useful a later.**

![http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/wiz_types.png](http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/wiz_types.png)

  * On the next step we could map the **method** to its corresponding ontology term. We don't need it right now, so clik on **Finish**. A dialog such as this one should appear. On it you can find the address of your brand new DAS source

![http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/wiz_final.png](http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/wiz_final.png)

The source will also appear on your list (along with a red cross to delete it if necessary) and in the public list if you left the **Private Source** unchecked.

You are now ready to use you DAS source.

## Going Further ##

We have so far used a GFF file and so have been able to skip many steps. You can create a small file with a spreadsheet program containing some regions (either real or invented, with just an Id, a type, a start and an end) and create a source from it. How would you proceed? what problems do you find? You can use the file at http://www.lsi.upc.edu/~bgel/research/easydas/tutorial/proteins.csv, which contains some protein data.

## easyDAS's accepted file formats ##
**GFF**
> The Generic Feature Format is a file format commonly used by many bioinformatics tools. It consists in 9 tab-separated columns describing the features. Many GFF file examples are available on the internet. You can use the one with the human microRNAs from mirBase as an example to try easyDAS. You can find more examples on the formats page

**Tabular**
> Any tabular file such as comma-separated values (CSV), tab-separated values (TSV, DAT), etc... can be used in easyDAS. Those files can be generated using many popular tools such as MS Excel, OpenOffice Calc, etc...