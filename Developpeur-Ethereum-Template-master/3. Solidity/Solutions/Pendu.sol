// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract Pendu is Ownable {
    enum State {
        GameNotStarted,
        GameStarted,
        GameEnded
    }

    State public CurrentState = State.GameNotStarted;

    uint256 NumberToGuess; // Nombre à deviner
    uint256 Tax; // Montant à payer pour jouer
    uint256 Pot; // Montant total investi
    address Winner; // Adresse du gagnant
    string Hint; // Indice pour deviner le nombre

    // uint MaxAttempts; // Nombre de tentatives maximum
    uint256[] ProposedNumbers; // Contient les nombres proposés
    address[] Players; // Contient les joueurs
    address[] Played; // Contient les joueurs ayant joués

    mapping(uint256 => bool) MapProposedNumbers; // Les nombres à true ont déjà été proposées
    mapping(address => bool) MapPlayers; // Contient les joueurs de la partie
    mapping(address => bool) MapPlayed; // Contient les joueurs ayant joués dans la partie

    event NumberProposed(uint256 proposedNumber); // Évènement à la proposition d'un nombre
    event PlayerAdded(address player); // Évènement à l'ajout d'un joueur
    event StateChanged(State state); // Évènement au changement d'état
    event TaxChanged(uint256 tax); // Évènement au changement de la taxe de jeu

    /**
     * N'autorise que les joueurs
     */
    modifier onlyPlayer() {
        require(MapPlayers[msg.sender], unicode"Vous n'êtes pas un joueur");
        _;
    }

    /**
     * Affiche l'état actuel
     */
    function showCurrentState() public view returns (State) {
        return CurrentState;
    }

    /**
     * Affiche la taxe pour jouer
     */
    function showTax() public view returns (uint256) {
        return Tax;
    }

    /**
     * Affiche le pot
     */
    function showPot() public view returns (uint256) {
        return Pot;
    }

    /**
     * Affiche le nombre à deviner
     */
    function showNumberToGuess() public view returns (uint256) {
        require(
            CurrentState == State.GameEnded,
            unicode"La partie n'est pas encore terminée"
        );
        return NumberToGuess;
    }

    /**
     * Affiche les joueurs
     */
    function showPlayers() public view returns (address[] memory) {
        return Players;
    }

    /**
     * Affiche les joueurs ayant joués
     */
    function showPlayed() public view returns (address[] memory) {
        return Played;
    }

    /**
     * Affiche les nombres proposés
     */
    function showProposedNumbers() public view returns (uint256[] memory) {
        return ProposedNumbers;
    }

    /**
     * Affiche l'indice pour deviner le nombre
     */
    function showHint() public view returns (string memory) {
        return Hint;
    }

    /**
     * Affiche le gagnant de la partie
     */
    function showWinner() public view returns (address) {
        require(
            CurrentState == State.GameEnded,
            unicode"La partie n'est pas encore terminée"
        );
        return Winner;
    }

    /**
     * Applique la tax de jeu
     */
    function setTax(uint256 _tax) public onlyOwner {
        require(
            CurrentState == State.GameNotStarted,
            unicode"La partie a déjà commencé"
        );
        Tax = _tax;
        emit TaxChanged(_tax);
    }

    /**
     * Ajoute un joueur
     */
    function addToPlayers(address _player) public onlyOwner {
        require(
            MapPlayers[_player] == false,
            unicode"L'adresse est déjà dans les joueurs"
        );
        require(
            CurrentState == State.GameNotStarted,
            unicode"La partie a déjà commencé"
        );
        MapPlayers[_player] = true;
        Players.push(_player);
        emit PlayerAdded(_player);
    }

    /**
     * Indique le nombre à deviner
     */
    function setNumberToGuess(uint256 _numberToGuess) public onlyOwner {
        require(
            CurrentState == State.GameNotStarted,
            unicode"La partie a déjà commencé"
        );
        NumberToGuess = _numberToGuess;
    }

    /**
     * Démarre la partie
     */
    function startGame() public onlyOwner {
        require(
            CurrentState == State.GameNotStarted,
            unicode"La partie a déjà commencé"
        );
        require(
            Players.length > 1,
            unicode"Il faut au moins deux joueurs pour démarrer une partie"
        );
        require(Tax > 0, unicode"La taxe n'a pas encore été assignée");
        require(
            NumberToGuess > 0,
            unicode"Le nombre à deviner n'a pas été choisi"
        );
        CurrentState = State.GameStarted;
        emit StateChanged(CurrentState);
    }

    /**
     * Proposition d'un chiffre
     */
    function proposeNumber(uint256 proposition) public payable onlyPlayer {
        require(
            MapProposedNumbers[proposition] == false,
            unicode"Le nombre a déjà été proposé"
        );
        require(
            CurrentState == State.GameStarted,
            unicode"La partie n'est pas en cours"
        );
        if (proposition == NumberToGuess) {
            // Victoire
            CurrentState = State.GameEnded;
            emit StateChanged(CurrentState);
            Winner = msg.sender;
        } else {
            Pot += msg.value; // La taxe à payer est ajoutée au pot
            Tax *= 2; // La taxe à payer double
            emit TaxChanged(Tax);
            
            if(MapPlayed[msg.sender] == false)
            {
                MapPlayed[msg.sender] = true;
                Played.push(msg.sender);
            }

            ProposedNumbers.push(proposition);
            MapProposedNumbers[proposition] = true;
            emit NumberProposed(proposition);
            Hint = proposition < NumberToGuess ? "C'est plus" : "C'est moins"; // Mise à jour de l'indice
            return;
        }

        Hint = "";
    }

    /**
     * Déclenchement de la victoire
     */
    function win() public {
        require(
            CurrentState == State.GameEnded,
            unicode"La partie n'est pas terminée"
        );
        require(Winner == msg.sender, unicode"Vous n'êtes pas le gagnant");

        payable(msg.sender).transfer(Pot);
        Pot = 0;
    }

    /**
     * Réinitialise le jeu
     */
    function resetGame() public onlyOwner {
        require(
            CurrentState == State.GameEnded,
            unicode"La partie n'est pas encore terminée"
        );
        CurrentState = State.GameNotStarted;
        delete NumberToGuess;
        delete Tax;
        delete Pot;
        delete Winner;

        for (uint256 i = 0; i < ProposedNumbers.length; i++) {
            MapProposedNumbers[ProposedNumbers[i]] = false;
        }

        for (uint256 i = 0; i < Players.length; i++) {
            MapPlayers[Players[i]] = false;
        }

        for (uint256 i = 0; i < Played.length; i++) {
            MapPlayed[Played[i]] = false;
        }

        delete ProposedNumbers;
        delete Players;
        delete Played;

        // emit les évènements ?
    }
}
