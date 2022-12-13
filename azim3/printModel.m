
close all
clear

load mat/createModel.mat m

print(m, "model-source/azim-core.model", saveas="model-source/azim-core.md", markdown=true, steady=false);
print(m, "model-source/azim-trend.model", saveas="model-source/azim-trend.md", markdown=true, steady=false);
print(m, "model-source/azim-world.model", saveas="model-source/azim-world.md", markdown=true, steady=false);

r = rephrase.Report("AzIM model code listing", "tableOfContents", true);

r + rephrase.Section("Core dynamics module");
r + rephrase.Text.fromFile("", "model-source/azim-core.md");

r + rephrase.Section("Long-run trend assumptions module");
r + rephrase.Text.fromFile("", "model-source/azim-core.md");

r + rephrase.Section("Rest of world assumptions module");
r + rephrase.Text.fromFile("", "model-source/azim-core.md");

build(r, "html/model-listing", "userStyle", "html/extra.css");

