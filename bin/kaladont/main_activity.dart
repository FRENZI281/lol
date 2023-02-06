import 'package:nyxx/nyxx.dart';

import '../consts.dart';
import '../main.dart';
import 'services/check_word.dart';
import 'services/word_check_formatter.dart';

void kaladontMainActivity({
  required IMessageReceivedEvent event,
  required EmbedBuilder embedder,
}) async {
  print(event.message.content);
  if (event.message.content != '') {
    if (!event.message.content.contains(" ")) {
      bool canContinue = WordCheckFormatter.getFirstTwoLetters(
              word: event.message.content.toLowerCase()) ==
          WordCheckFormatter.getLastTwoLetters(
              word: savedWord.currentWord.toLowerCase(),
              length: savedWord.currentWord.length - 1);
      isProcessingWord = true;
      if (gameState.lastPlayerId == event.message.author.id.toString() &&
          canContinue) {
        embedder.description =
            "Ne možete nastaviti vlastiti niz.\nTrenutna riječ: ${savedWord.currentWord}";
        await event.message.channel.sendMessage(MessageBuilder.embed(embedder));
        isProcessingWord = false;
        return;
      }
      if (Globals.usedWords.contains(event.message.content.toLowerCase())) {
        embedder.description = "Riječ je već korištena!";
        embedder.color = DiscordColor.yellow;
        await event.message.channel.sendMessage(MessageBuilder.embed(embedder));
        isProcessingWord = false;
        return;
      }
      savedWord = await checkWord(
          savedWord: savedWord,
          wordToCheck: event.message.content.toLowerCase());
      if (!savedWord.previousExistsInDictionary) {
        embedder.description =
            "Riječ koju ste upisali ne postoji u rječniku!\nRiječ treba početi sa ${WordCheckFormatter.getLastTwoLetters(word: savedWord.currentWord.toLowerCase(), length: savedWord.currentWord.length - 1)}";
        embedder.color = DiscordColor.red;
        await event.message.channel.sendMessage(MessageBuilder.embed(embedder));
        isProcessingWord = false;
        return;
      }
      if (savedWord.victory) {
        embedder.color = DiscordColor.green;
        embedder.description = "Čestitamo! Pobijedili ste!";
        gameState.isKaladontStarted = false;
        gameState.lastPlayerId = '';
        Globals.usedWords.clear();
        await event.message.channel.sendMessage(MessageBuilder.embed(embedder));
      } else if (savedWord.lastGuess) {
        embedder.color = DiscordColor.turquoise;
        String possibleAnswers;
        savedWord.possibleAnswers == 1000
            ? possibleAnswers = '1000+'
            : possibleAnswers = savedWord.possibleAnswers.toString();
        gameState.lastPlayerId = event.message.author.id.toString();
        Globals.usedWords.add(savedWord.currentWord);
        embedder.description =
            "Nova riječ: ${savedWord.currentWord}\nMogućih odgovora: $possibleAnswers";

        await event.message.channel.sendMessage(MessageBuilder.embed(embedder));
        isProcessingWord = false;
        return;
      } else {
        embedder.color = DiscordColor.red;
        embedder.description =
            "Niste dobro nastivili buhtlin niz. Pokušajte ponovno. Trenutna riječ: ${savedWord.currentWord}";
        await event.message.channel.sendMessage(MessageBuilder.embed(embedder));
        isProcessingWord = false;
        return;
      }
    }
  }
}
