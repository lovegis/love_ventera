from xmltoxsd import XSDGenerator
from xml2db import DataModel

import pandas as pd
import xml.etree.ElementTree as et

def xmltoxsd_xml2db_attempt():

    generator = XSDGenerator()
    xsd_schema = generator.generate_xsd("data/xml/sample_test_fixed.xml", min_occurs="0")
    #print(xsd_schema)
    with open("data/xml/sample_test_fixed.xsd", "w") as f:
        f.write(xsd_schema)
        f.close() # Create a DataModel object from an XSD file


    data_model = DataModel(
        xsd_file="data/xml/sample_test_fixed.xsd",
        db_schema="ventera",
        connection_string="postgresql+psycopg2://postgres:postgres@localhost:5434/xml_model",
        model_config={},
        )

    with open(f"data/xml/sample_test_fixed_data_model_erd.md", "w") as f:
        f.write(data_model.get_entity_rel_diagram())
        f.close()

    # Parse an XML file based on this XSD schema
    document = data_model.parse_xml(xml_file="data/xml/sample_test_fixed.xml")

    # Load data into the database, creating target tables if need be
    document.insert_into_target_tables()

    return


def main():
    # generator = XSDGenerator()
    # xsd_schema = generator.generate_xsd("data/xml/sample_test_fixed.xml", min_occurs="0")
    # #print(xsd_schema)
    # with open("data/xml/sample_test_fixed.xsd", "w") as f:
    #     f.write(xsd_schema)
    #     f.close()# Create a DataModel object from an XSD file

    xtree = et.parse("data/xml/sample_test_fixed.xml")
    xroot = xtree.getroot()

    print (xroot.items())
    for node in xroot.iter():
        print(node)

    df = pd.read_xml("data/xml/sample_test_fixed.xml")
    print(df)
if __name__ == '__main__':
    main()
