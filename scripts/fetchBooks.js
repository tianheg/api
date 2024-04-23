import * as cheerio from 'cheerio';
import * as fs from 'fs';

const url = 'https://read.tianheg.org/';

fetch(url)
  .then((response) => response.text())
  .then((html) => {
    const $ = cheerio.load(html);
    const links = $('.VPSidebar a.VPLink');

    const jsonArr = [];

    links.each((index, element) => {
      const linkText = $(element).text();
      const linkHref = $(element).attr('href');

      const linkData = {
        text: linkText,
        href: 'https://read.tianheg.org' + linkHref,
      };

      jsonArr.push(linkData);
    });

    const jsonData = JSON.stringify(jsonArr, null, 2);

    fs.writeFile('./data/books.js', `export default ${jsonData}`, (err) => {
      if (err) {
        console.error('Error writing JSON file:', err);
      } else {
        console.log('JSON file has been written successfully.');
      }
    });
  })
  .catch((error) => {
    console.error('Error fetching the VitePress site:', error);
  });
