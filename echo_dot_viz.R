
library(tidytext)
library(tidyverse)
library(hrbrthemes)
library(ggthemes)
library(udpipe)

df <- read_csv("echo_dot_reviews.csv") %>%
  mutate(id = row_number())

#language_nodel <- udpipe_download_model(language = "english-ewt")
#ud_english <- udpipe_load_model("english-ewt-ud-2.3-181115.udpipe")

# tagged <- udpipe(ud_english, x = df$review,doc_id = df$id)
# 
# tagged <- tagged %>%
#   select(doc_id,token,lemma,upos)
# 
# write_csv(tagged,"echo_dot_tagged.csv")

df <- df %>%
  filter(stars >= 4 |stars <= 2) %>%
  mutate(valence = if_else(stars >=4,"Good","Bad")) %>%
  select(doc_id = id,valence)

tagged <- read_csv("echo_dot_tagged.csv")

tagged <- tagged %>%
  inner_join(df) %>%
  mutate(token = tolower(token)) %>%
  #mutate(word = str_replace(word,"customerservice","customer service")) %>%
  anti_join(stop_words, by=c("token" = "word")) %>%
  filter(upos == "ADJ"|upos =="NOUN",
         token !="pmjimlise|echo|dot") %>%
  mutate(upos = recode(upos,ADJ = "Adjectives",NOUN = "Nouns"))

tagged <-tagged %>% 
  group_by(upos) %>%
  count(lemma, valence) %>%
  filter(n >= 10) %>%
  spread(valence, n, fill = 0) %>%
  mutate_each(list(~(. + 1) / sum(. + 1)), -lemma) %>%
  mutate(logratio = log2(Good / Bad)) %>%
  arrange(desc(logratio)) %>%
  group_by(upos,logratio > 0) %>%
  top_n(10, abs(logratio)) %>%
  ungroup() %>%
  mutate(word = reorder_within(lemma, logratio,upos,),
         word2 = str_split(word,"_") %>% map(1)%>% unlist())

tagged %>%
  ggplot(aes(word, logratio, fill = logratio < 0)) +
  geom_bar(stat = "identity") +
  facet_wrap(~upos,scales="free") +
  coord_flip() +
  ylab("Good / Bad log ratio") +
  scale_x_discrete(breaks = tagged$word,labels = tagged$word2) +
  theme_ipsum_rc() +
  scale_fill_tableau(labels = c("Good","Bad")) +
  theme(plot.margin = margin(2,1, 2,1, "cm"),
        plot.title = element_text(size=30),
        axis.text.y = element_text(size = 24,
                                   margin = margin(r = .3, unit = "cm")),
        axis.text.x = element_text(size = 20),
        panel.grid = element_blank(),
        axis.title.y = element_blank(),
        axis.title.x = element_text(size = 24,margin=margin(t=1,unit="cm")),
        legend.title = element_blank(),
        legend.key.size = unit(1.5, "cm"),
        legend.text = element_text(size=24),
        strip.text = element_text(size=28,margin=margin(b=1,unit="cm")))

ggsave("echo_dot_log_ratio.png",width=17,height = 12)


