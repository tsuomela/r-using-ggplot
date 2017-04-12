####################################
# R script for social sciences and humanities vis demos
# 04/13/17
####################################

# 0 - loading libraries
library(dplyr)
library(stringr)
library(ggplot2)

#####################################
# social science examples
####################################

# 1 - gapminder data, using the r package

glimpse(gapminder)


# simple line plot for 5 countries
h_countries <- c("Egypt", "Haiti", "Romania", "Thailand", "Venezuela")
h_dat <- droplevels(subset(gapminder, country %in% h_countries))
h_dat$country <- with(h_dat, reorder(country, lifeExp, max))
ggplot(h_dat, aes(x = year, y = lifeExp)) +
  geom_line(aes(color = country)) +
  scale_colour_manual(values = country_colors) +
  guides(color = guide_legend(reverse = TRUE))

# spaghetti plot for lots of countries
ggplot(subset(gapminder, continent != "Oceania"),
       aes(x = year, y = lifeExp, group = country, color = country)) +
  geom_line(lwd = 1, show_guide = FALSE) + facet_wrap(~ continent) +
  scale_color_manual(values = country_colors) +
  theme_bw() + theme(strip.text = element_text(size = rel(1.1)))

# bubble plot for lots of countries
gap_bit <- subset(gapminder, year == 2007 & continent != "Oceania")
gap_bit <- gap_bit[with(gap_bit, order(continent, -1 * pop)), ]
ggplot(gap_bit, aes(x = gdpPercap, y = lifeExp, size = pop)) +
  scale_x_log10(limits = c(150, 115000)) + ylim(c(16, 96)) +
  geom_point(pch = 21, color = 'grey20', show.legend = F) +
  scale_size_area(max_size = 40) +
  facet_wrap(~ continent) + coord_fixed(ratio = 1/43) +
  aes(fill = country) + scale_fill_manual(values = country_colors) +
  theme_bw() + theme(strip.text = element_text(size = rel(1.1)))

# 2 - network analysis, example from Kieran Healy
# https://kieranhealy.org/blog/archives/2013/06/09/using-metadata-to-find-paul-revere/


data <- as.matrix(read.csv("../../github-repo/revere/data/PaulRevereAppD.csv",row.names=1))

person.net <- data %*% t(data)
group.net <- t(data) %*% data

diag(group.net) <- NA
diag(person.net) <- NA

person.g <- graph.adjacency(person.net,mode="undirected",
                            weighted=NULL, diag=FALSE)

group.g <- graph.adjacency(group.net, weighted=TRUE,
                           mode="undirected", diag=FALSE)

revere.g <- fortify(group.g)
revere.p <- fortify(person.g)

person2.net <- data %*% t(data)
diag(person2.net) <- NA
person2.g <- graph.adjacency(person2.net, weighted=TRUE,
                           mode="undirected", diag=FALSE)

revere.p.2 <- fortify(person2.g)

# from the geomnet github page

ggplot(data = revere.g,
  aes(from_id = from, to_id = to, linewidth = weight)) +
  geom_net(layout.alg = "fruchtermanreingold",
           labelon = TRUE, size = 1, labelcolour = 'black',
           ecolour = "grey70", repel = T) +
  theme_net()

ggplot(data = revere.p.2,
  aes(from_id = from, to_id = to, size = weight)) +
  geom_net(layout.alg = "fruchtermanreingold",
           labelon = revere.p.2$weight == 4,
           #aes(label = ifelse(..weight.. > 3, ..from_id.., NA)),
           linewidth = 0.01) +
  theme_net()
